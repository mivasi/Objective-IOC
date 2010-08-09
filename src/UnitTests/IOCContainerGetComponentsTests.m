//
//  IOCContainerGetComponentsTests.m
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IOCContainerGetComponentsTests.h"
#import <OCMock/OCMock.h>
#import "TestClasses.h"

#import "MVIOCFactory.h"
#import "MVIOCCache.h"

#import <objc/runtime.h>

#pragma mark -
#pragma mark TestSuite

@implementation IOCContainerGetComponentsTests

@synthesize container = _container;

- (void)setUp {
    self.container = [[[MVIOCContainer alloc] init] autorelease];
    [self.container addComponent:[MVTestCompositor class]];
    [self.container addComponent:[MVTestComposite class]];    
}

- (void)tearDown {
    self.container = nil;
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testGetComponentWithOneDependencyComponent {
    MVTestCompositor *compositor = [self.container getComponent:[MVTestCompositor class]];
    STAssertTrue([compositor.composite isKindOfClass:[MVTestComposite class]], @"Bad compositor");
}

- (void)testGetComponentCreatedByFactory {
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCFactory)];
    [self.container setFactory:factory];

    [[factory expect] createInstanceFor:[MVTestComposite class]];
    [self.container getComponent:[MVTestComposite class]];
    [factory verify];
}

- (void)testGetComponentAddedAsInstance {
    [self.container addComponent:self];
    STAssertTrue([self.container getComponent:[IOCContainerGetComponentsTests class]] == self, @"Bad component");
}

- (void)testGetComponentAddedAsInstanceWithAlias {
    [self.container addComponent:self representing:@"MyTest"];
    STAssertTrue([self.container getComponent:@"MyTest"] == self, @"Bad component");    
}

#endif

@end