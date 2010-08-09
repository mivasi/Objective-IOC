//
//  IOCContainerTests.m
//  IOC
//
//  Created by Michal Vašíček on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IOCContainerAddComponentsTests.h"
#import "MVIOCPropertyFactory.h"
#import "MVIOCContainer.h"
#import "MVIOCCache.h"
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
    id<MVIOCFactory> factory = [[[MVIOCPropertyFactory alloc] init] autorelease];
    [self.container setFactory:factory];
}

- (void)testAddComponentWithCustomFactory {
    id defaultFactory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    [self.container setFactory:defaultFactory];
    id forComponentFactory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    
    [[self.container withFactory:forComponentFactory] addComponent:[IOCContainerAddComponentsTests class]];
    [self.container addComponent:[MVIOCPropertyFactory class]];
    
    [[forComponentFactory expect] createInstanceFor:[IOCContainerAddComponentsTests class]];
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
    [forComponentFactory verify];
    
    [[defaultFactory expect] createInstanceFor:[MVIOCPropertyFactory class]];
    [self.container getComponent:[MVIOCPropertyFactory class]];
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
    
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    [[[factory stub] andThrow:exception] createInstanceFor:[IOCContainerAddComponentsTests class]];
    [self.container setFactory:factory];
    
    id cache = [OCMockObject niceMockForProtocol:@protocol(MVIOCCache)];
    [[[cache stub] andReturn:self] getInstanceWithKey:@"IOCContainerAddComponentsTests"];
    
    [[self.container withCache:cache] addComponent:[IOCContainerAddComponentsTests class]];
    
    [self.container getComponent:[IOCContainerAddComponentsTests class]];
}

- (void)testAddComponentWithExplicitDepsInVarg {
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    [[factory expect] createInstanceFor:[MVTestProtocolCompositor class] withDeps:[OCMArg checkWithSelector:@selector(hasFactoryGetDepArgumentAsArray:) onObject:self]];
    [self.container setFactory:factory];
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
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    [[factory expect] createInstanceFor:[MVTestProtocolCompositor class] withDeps:[OCMArg checkWithSelector:@selector(hasFactoryGetDepArgumentAsDictionary:) onObject:self]];
    
    [self.container setFactory:factory];
    
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

#endif


@end
