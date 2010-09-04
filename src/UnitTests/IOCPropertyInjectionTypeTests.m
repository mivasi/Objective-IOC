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

#import "IOCPropertyInjectionTypeTests.h"
#import <OCMock/OCMock.h>
#import "TestClasses.h"

#import <objc/runtime.h>

@implementation IOCPropertyInjectionTypeTests

@synthesize factory = _factory;

- (void)setUp {
    self.factory = [[[MVIOCPropertyInjectionType alloc] init] autorelease];
}

- (void)tearDown {
    self.factory = nil;
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testGetComponentFromFactoryShouldnotInstantiateLazyDeps {
    id container = [OCMockObject mockForClass:[MVIOCContainer class]];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:@"Get component should not be called, when its lazy"
                                                   userInfo:nil];
    [[[container stub] andThrow:exception] getComponent:[OCMArg any]];
    [self.factory setContainer:container];
    [self.factory createInstanceFor:[MVTestLazyCompositor class] withDeps:nil initSelector:nil initParams:nil];
}

- (void)testGetComponentAfterQueryingIt {
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];    
    [[container expect] getComponent:@"MVTestComposite"];
    
    [self.factory setContainer:container];
    MVTestLazyCompositor *lazyCompositor = [self.factory createInstanceFor:[MVTestLazyCompositor class] withDeps:nil initSelector:nil initParams:nil];
    lazyCompositor.composite;
    [container verify];
}

- (void)testCreateLazyComponentJustOneTime {
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];    
    
    [self.factory setContainer:container];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:@"Get component should be called just for first time, when accessing to lazy loaded component"
                                                   userInfo:nil];
    
    MVTestLazyCompositor *lazyCompositor = [self.factory createInstanceFor:[MVTestLazyCompositor class] withDeps:nil initSelector:nil initParams:nil];
    [[[container stub] andReturn:self] getComponent:@"MVTestComposite"];
    lazyCompositor.composite;
    
    [[[container stub] andThrow:exception] getComponent:@"MVTestComposite"];
    lazyCompositor.composite;
    [container verify];
}

- (void)testCreateComponentWithExplicitDeps {
    id container = [OCMockObject mockForClass:[MVIOCContainer class]];
    [[container expect] getComponent:[MVTestComposite class]];
    [[container expect] getComponent:[MVTestProtocolImplementation class]];
    [[container expect] getComponent:[MVTestProtocolImplementation class]];

    [self.factory setContainer:container];
    
    NSDictionary *explicitDeps = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [MVTestProtocolImplementation class], @"lazyComposite",
                                  [MVTestProtocolImplementation class], @"manualComposite", 
                                  [MVTestComposite class], @"composite", nil];
    
    MVTestCompositor *component = [self.factory createInstanceFor:[MVTestCompositor class] withDeps:explicitDeps initSelector:nil initParams:nil];
    component.lazyComposite;
    [container verify];    
}

- (void)testCreateComponentWithCustomInit {
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];
    [[[container stub] andReturn:[MVTestCustomInitClass class]] getComponent:[OCMArg any]];
    NSArray *params = [NSArray arrayWithObjects:@"NibFile", nil];
    [self.factory setContainer:container];
    MVTestCustomInitClass *instance = [self.factory createInstanceFor:[MVTestCustomInitClass class] withDeps:nil initSelector:@selector(initWithObject:) initParams:params];
    STAssertTrue([instance.object isEqual:@"NibFile"], @"Init take bad argument");
}

#endif

@end
