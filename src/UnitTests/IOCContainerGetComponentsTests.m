//
//  IOCContainerGetComponentsTests.m
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IOCContainerGetComponentsTests.h"
#import <OCMock/OCMock.h>
#import "MVIOCFactory.h"

@class MVTestComposite;

@interface MVTestCompositor : NSObject {
    MVTestComposite *injComposite;
}
@property(nonatomic, retain) MVTestComposite *composite;
@end

@interface MVTestComposite : NSObject {
    MVTestComposite *injComposite;
}
@end

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

#endif

@end

#pragma mark -
#pragma mark TestClasses implementations

@implementation MVTestCompositor
@synthesize composite = injComposite;
@end

@implementation MVTestComposite
@end


