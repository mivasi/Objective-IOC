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
#import <OCMock/OCMock.h>

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

#endif


@end
