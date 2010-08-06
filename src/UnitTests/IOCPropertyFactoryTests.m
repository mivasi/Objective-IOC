//
//  IOCContainerAddLazyComponent.m
//  IOC
//
//  Created by Michal Vašíček on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IOCPropertyFactoryTests.h"
#import <OCMock/OCMock.h>
#import "TestClasses.h"

#import <objc/runtime.h>

@implementation IOCPropertyFactoryTests

@synthesize factory = _factory;

- (void)setUp {
    self.factory = [[[MVIOCPropertyFactory alloc] init] autorelease];
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
    [self.factory createInstanceFor:[MVTestLazyCompositor class]];
}

- (void)testGetComponentAfterQueryingIt {
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];    
    [[container expect] getComponent:@"MVTestComposite"];
    
    [self.factory setContainer:container];
    MVTestLazyCompositor *lazyCompositor = [self.factory createInstanceFor:[MVTestLazyCompositor class]];
    lazyCompositor.composite;
    [container verify];
}

- (void)testCreateLazyComponentJustOneTime {
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];    
    
    [self.factory setContainer:container];
    NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                     reason:@"Get component should be called just for first time, when accessing to lazy loaded component"
                                                   userInfo:nil];
    
    MVTestLazyCompositor *lazyCompositor = [self.factory createInstanceFor:[MVTestLazyCompositor class]];
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
    
    MVTestCompositor *component = [self.factory createInstanceFor:[MVTestCompositor class] withDeps:explicitDeps];
    component.lazyComposite;
    [container verify];    
}

#endif

@end
