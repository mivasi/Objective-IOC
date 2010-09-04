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
