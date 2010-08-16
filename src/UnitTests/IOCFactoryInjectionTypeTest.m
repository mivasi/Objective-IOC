//
//  IOCFactoryFactoryTest.m
//  IOC
//
//  Created by Michal Vašíček on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IOCFactoryInjectionTypeTest.h"
#import "OCMock.h"

@implementation IOCFactoryInjectionTypeTest

@synthesize injectionType = _injectionType;

- (void)setUp {
    self.injectionType = [[[MVIOCFactoryInjectionType alloc] init] autorelease];
}

- (void)tearDown {
    self.injectionType = nil;
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testCreateInstance {
    id factoryInjectionType = [OCMockObject mockForProtocol:@protocol(MVIOCInjectionType)];
    [[[factoryInjectionType stub] andReturn:self] createInstanceFor:[IOCFactoryInjectionTypeTest class] withDeps:nil initSelector:nil initParams:nil];
    self.injectionType.factoryInjectionType = factoryInjectionType;
    id instance = [self.injectionType createInstanceFor:[IOCFactoryInjectionTypeTest class] withDeps:nil initSelector:nil initParams:nil];
    STAssertTrue([instance isEqual:@"Created"], @"Create instance on factory object not called");
}

- (void)testPropagationOfContainerIntoFactoryInjectionTypeObject1 {
    id factoryInjectionType = [OCMockObject mockForProtocol:@protocol(MVIOCInjectionType)];
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];
    
    [[factoryInjectionType expect] setContainer:container];
    [self.injectionType setContainer:container];
    self.injectionType.factoryInjectionType = factoryInjectionType;
    [factoryInjectionType verify];
}

- (void)testPropagationOfContainerIntoFactoryInjectionTypeObject2 {
    id factoryInjectionType = [OCMockObject mockForProtocol:@protocol(MVIOCInjectionType)];
    id container = [OCMockObject niceMockForClass:[MVIOCContainer class]];
    
    [[factoryInjectionType expect] setContainer:container];
    self.injectionType.factoryInjectionType = factoryInjectionType;
    [self.injectionType setContainer:container];
    [factoryInjectionType verify];
}

#endif

- (id)createInstance {
    return @"Created";
}

@end
