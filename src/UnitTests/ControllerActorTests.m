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

#import "ControllerActorTests.h"

@implementation ControllerActorTests

@synthesize controllerActor = _controllerActor;
@synthesize view = _view;

- (void)setUp {
    self.controllerActor = [[[MVIOCControllerActor alloc] init] autorelease];
}

- (void)tearDown {
    self.controllerActor = nil;
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testMakeActorOnInstance {
    [self.controllerActor makeActOnInstance:self];
    STAssertTrue([self respondsToSelector:@selector(originalSetView:)], @"Original metod for replace setView was not added");
    self.view = [[[UIView alloc] init] autorelease];
    STAssertTrue([self.view respondsToSelector:@selector(owningController)], @"Method for get owningController was not added");
    STAssertTrue([self.view performSelector:@selector(owningController)] == self, @"Bad owning controller setted");
    ControllerActorTestsView *subView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:subView];
    STAssertTrue(subView.owningController == self, @"Bad owning controller for subView");
}

#endif

@end

@implementation ControllerActorTestsView 

@dynamic owningController;

@end

@implementation ControllerActorTestsViewAnother

@end