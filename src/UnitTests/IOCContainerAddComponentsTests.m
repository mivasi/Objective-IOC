// 
// Copyright 2010 MICHAL VASICEK
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 

#import "IOCContainerAddComponentsTests.h"
#import "MVIOCPropertyInjectionType.h"
#import "MVIOCContainer.h"
#import "MVIOCCache.h"
#import "MVIOCActor.h"
#import <OCMock/OCMock.h>
#import "TestClasses.h"

@implementation IOCContainerAddComponentsTests

@synthesize container = _container;

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)setUp {
    self.container = [[[MVIOCContainer alloc] init] autorelease];
}

- (void)testAddComponentClass {
    [self.container addComponent:[IOCContainerAddComponentsTests class]];
    id component = [self.container getComponent:[IOCContainerAddComponentsTests class]];
    STAssertTrue([component isKindOfClass:[IOCContainerAddComponentsTests class]], @"Returned component has right type");
}

- (void)testAddComponentClassAsTypeRepresenterClass {
    [self.container addComponent:[IOCContainerAddComponentsTests class] representing:[SenTest class]];
    id component = [self.container getComponent:[SenTest class]];
    STAssertTrue([component isKindOfClass:[IOCContainerAddComponentsTests class]], @"Returned component has right type");
}

- (void)testAddComponentClassAsNamedRepresenterString {
    [self.container addComponent:[IOCContainerAddComponentsTests class] representing:@"SenTest"];
    id component = [self.container getComponent:[SenTest class]];
    STAssertTrue([component isKindOfClass:[IOCContainerAddComponentsTests class]], @"Returned component has right type");
}

- (void)testAddComponentClassAsTypeRepresentantProtocol {
    [self.container addComponent:[IOCContainerAddComponentsTests class] representing:@protocol(IOCContainerTestsProtocol)];
    id component = [self.container getComponent:@protocol(IOCContainerTestsProtocol)];
    STAssertTrue([component isKindOfClass:[IOCContainerAddComponentsTests class]], @"Returned component has right type");
}

- (void)testGetComponentByString {
    [self.container addComponent:[IOCContainerAddComponentsTests class] representing:@protocol(IOCContainerTestsProtocol)];
    id component = [self.container getComponent:@"IOCContainerTestsProtocol"];
    STAssertTrue([component isKindOfClass:[IOCContainerAddComponentsTests class]], @"Returned component has right type");
}

- (void)testSetDefaultFactory {
    id<MVIOCInjectionType> factory = [[[MVIOCPropertyInjectionType alloc] init] autorelease];
    [self.container setInjectionType:factory];
}

- (void)testAddComponentWithCustomFactory {
    id defaultFactory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [self.container setInjectionType:defaultFactory];
    id forComponentFactory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    
    [[self.container withInjectionType:forComponentFactory] addComponent:[IOCContainerAddComponentsTests class]];
    [self.container addComponent:[MVIOCPropertyInjectionType class]];
    
    [[forComponentFactory expect] createInstanceFor:[IOCContainerAddComponentsTests class] withDeps:nil initSelector:nil initParams:nil];
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
    [forComponentFactory verify];
    
    [[defaultFactory expect] createInstanceFor:[MVIOCPropertyInjectionType class] withDeps:nil initSelector:nil initParams:nil];
    [self.container getComponent:[MVIOCPropertyInjectionType class]];
    [defaultFactory verify];
}

- (void)testAddComponentWithCachingStrategyWillStoreInstance {
    id cache = [OCMockObject niceMockForProtocol:@protocol(MVIOCCache)];

    [[self.container withCache:cache] addComponent:[IOCContainerAddComponentsTests class]];
    
    [[cache expect] storeInstance:[OCMArg any] withKey:@"IOCContainerAddComponentsTests"];
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
    [cache verify];
}

- (void)testAddComponentWithCacheWillReturnInstanceFromCache {
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:@"Factory should not be called when object is cached"
                                                   userInfo:nil];
    
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [[[factory stub] andThrow:exception] createInstanceFor:[IOCContainerAddComponentsTests class] withDeps:nil initSelector:nil initParams:nil];
    [self.container setInjectionType:factory];
    
    id cache = [OCMockObject niceMockForProtocol:@protocol(MVIOCCache)];
    [[[cache stub] andReturn:self] getInstanceWithKey:@"IOCContainerAddComponentsTests"];
    
    [[self.container withCache:cache] addComponent:[IOCContainerAddComponentsTests class]];
    
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
}

- (void)testAddComponentWithExplicitDepsInVarg {
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [[factory expect] createInstanceFor:[MVTestProtocolCompositor class]
                               withDeps:[OCMArg checkWithSelector:@selector(hasFactoryGetDepArgumentAsArray:) onObject:self]
                           initSelector:nil
                             initParams:nil];
    
    [self.container setInjectionType:factory];
    [[self.container withDeps:[MVTestProtocolImplementation class], nil] addComponent:[MVTestProtocolCompositor class]];
    [self.container getComponent:[MVTestProtocolCompositor class]];
    [factory verify];
}

- (BOOL)hasFactoryGetDepArgumentAsArray:(NSArray *)arg {
    if ([arg count] == 1) {
        if ([[arg objectAtIndex:0] isEqual:[MVTestProtocolImplementation class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)testAddComponentWithExplicitDepsInDictionary {
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [[factory expect] createInstanceFor:[MVTestProtocolCompositor class]
                               withDeps:[OCMArg checkWithSelector:@selector(hasFactoryGetDepArgumentAsDictionary:) onObject:self] 
                           initSelector:nil
                             initParams:nil];
    
    [self.container setInjectionType:factory];
    
    NSDictionary *deps = [NSDictionary dictionaryWithObjectsAndKeys:[MVTestProtocolImplementation class], @"composite", nil];
    
    [[self.container withDepsDictionary:deps] addComponent:[MVTestProtocolCompositor class]];
    [self.container getComponent:[MVTestProtocolCompositor class]];
    [factory verify];
}

- (BOOL)hasFactoryGetDepArgumentAsDictionary:(NSDictionary *)arg {
    if ([arg count] == 1) {
        if ([[arg objectForKey:@"composite"] isEqual:[MVTestProtocolImplementation class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)testSetDefaultCacheStrategy {
    id cache = [OCMockObject mockForProtocol:@protocol(MVIOCCache)];
    [[[cache stub] andReturn:self] getInstanceWithKey:@"IOCContainerAddComponentsTests"];
    self.container.cache = cache;
    
    [[self.container withCache] addComponent:[IOCContainerAddComponentsTests class]];
    id instance = [self.container getComponent:@"IOCContainerAddComponentsTests"];
    STAssertTrue(instance == self, @"Bad component");
}

- (void)testAddComponentClassWithCustomInit {
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [[factory expect] createInstanceFor:[MVTestCustomInitClass class]
                               withDeps:nil
                           initSelector:@selector(initWithObject:)
                             initParams:[OCMArg checkWithSelector:@selector(checkInitWithCustomSelectorParams:) onObject:self]];
    
    self.container.injectionType = factory;
    [[self.container withInitSelector:@selector(initWithObject:) params:self, self, nil] addComponent:[MVTestCustomInitClass class]];
    [self.container getComponent:[MVTestCustomInitClass class]];
    [factory verify];
}

- (BOOL)checkInitWithCustomSelectorParams:(NSArray *)params {
    if ([params count] == 2) {
        return YES;
    }
    return NO;
}

- (void)testAddComponentWithActAs {
    id actor = [OCMockObject mockForProtocol:@protocol(MVIOCActor)];
    [[actor expect] makeActOnInstance:[OCMArg checkWithSelector:@selector(checkCallActorMakeActOnInstance:) onObject:self]];
    [[self.container actAs:actor] addComponent:[IOCContainerAddComponentsTests class]];
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
    
    [actor verify];
}

- (BOOL)checkCallActorMakeActOnInstance:(id)instance {
    if ([instance isKindOfClass:[IOCContainerAddComponentsTests class]]) {
        return YES;
    }
    return NO;
}

#endif


@end
