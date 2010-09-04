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

#import "IOCContainerGetComponentsTests.h"
#import <OCMock/OCMock.h>
#import "TestClasses.h"

#import "MVIOCInjectionType.h"
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
    id factory = [OCMockObject niceMockForProtocol:@protocol(MVIOCInjectionType)];
    [self.container setInjectionType:factory];

    [[factory expect] createInstanceFor:[MVTestComposite class]
                               withDeps:nil
                           initSelector:nil
                             initParams:nil];
    
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