//
//  MVIOCPropertyTests.m
//  IOC
//
//  Created by Michal Vašíček on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
    
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(objcProperty) encoding:NSUTF8StringEncoding];
    NSLog(@"%@", propertyAttributes);
    
    MVIOCProperty *property = [[[MVIOCProperty alloc] initWithObjCProperty:objcProperty] autorelease];
    STAssertTrue([property.name isEqual:@"assignAttrProperty"], @"Property has bad name");
    STAssertTrue([property.type isEqual:NSStringFromClass([SenTestCase class])], @"Property has bad type");
    STAssertTrue([property.variableName isEqual:@"_assignAttrProperty"], @"Property has bad variable name");    
}

#endif

@end
