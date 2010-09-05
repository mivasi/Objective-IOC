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

#import "MVIOCPropertyTests.h"
#import <objc/runtime.h>

@implementation MVIOCPropertyTests

@synthesize classProperty = _classProperty;
@synthesize protocolProperty = _protocolProperty;
@synthesize assignAttrProperty = _assignAttrProperty;

@dynamic lazyProperty;

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testCreatePropertyWithObjectiveCProperty {
    objc_property_t objcProperty = class_getProperty([self class], "classProperty");
    MVIOCProperty *property = [[[MVIOCProperty alloc] initWithObjCProperty:objcProperty] autorelease];
    STAssertFalse(property.lazy, @"Property should not to be lazy");
    STAssertTrue([property.name isEqual:@"classProperty"], @"Property has bad name");
    STAssertTrue([property.type isEqual:NSStringFromClass([SenTestCase class])], @"Property has bad type");
    STAssertTrue([property.variableName isEqual:@"_classProperty"], @"Property has bad variable name");
}

- (void)testGetTypeOfProtocolProperty {
    objc_property_t objcProperty = class_getProperty([self class], "protocolProperty");
    MVIOCProperty *property = [[[MVIOCProperty alloc] initWithObjCProperty:objcProperty] autorelease];
    STAssertTrue([property.type isEqual:NSStringFromProtocol(@protocol(NSCoding))], @"Property has bad type");
}

- (void)testGetLazyProperty {
    objc_property_t objcProperty = class_getProperty([self class], "lazyProperty");
    MVIOCProperty *property = [[[MVIOCProperty alloc] initWithObjCProperty:objcProperty] autorelease];
    STAssertTrue(property.lazy, @"Property is not lazy");    
}

- (void)testAssignProperty {
    objc_property_t objcProperty = class_getProperty([self class], "assignAttrProperty");
    
    [NSString stringWithCString:property_getAttributes(objcProperty) encoding:NSUTF8StringEncoding];
    
    MVIOCProperty *property = [[[MVIOCProperty alloc] initWithObjCProperty:objcProperty] autorelease];
    STAssertTrue([property.name isEqual:@"assignAttrProperty"], @"Property has bad name");
    STAssertTrue([property.type isEqual:NSStringFromClass([SenTestCase class])], @"Property has bad type");
    STAssertTrue([property.variableName isEqual:@"_assignAttrProperty"], @"Property has bad variable name");    
}

#endif

@end
