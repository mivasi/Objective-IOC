//
//  MVIOCProperty.m
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCProperty.h"
#import "MVIOCContainer.h"

@implementation MVIOCProperty

@synthesize name = _propertyName;
@synthesize type = _propertyType;
@synthesize lazy = _lazy;
@synthesize variableName = _variableName;

- (id)initWithObjCProperty:(objc_property_t)objcProperty {
    if (self = [super init]) {
        _objcProperty = objcProperty;
    }
    
    //T@"ClassToIntrospect",&,N,V_ctiProp
    //T@"<ProtocolToTest>",C,D,N
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(objcProperty) encoding:NSUTF8StringEncoding];
    NSArray *attributes = [propertyAttributes componentsSeparatedByString:@","];
    _propertyName = [[NSString stringWithCString:property_getName(objcProperty) encoding:NSUTF8StringEncoding] retain];
    
    NSString *variableTypePart = [attributes objectAtIndex:0];
    if ([variableTypePart characterAtIndex:3] == '<') {
        _propertyType = [[variableTypePart substringFromIndex:4] substringToIndex:([variableTypePart length] - 4 - 2)];
    } else {
        _propertyType = [[variableTypePart substringFromIndex:3] substringToIndex:([variableTypePart length] - 3 - 1)];
    }
    [_propertyType retain];
    
    _variableName = [[[attributes lastObject] substringFromIndex:1] retain];
    
    if ([attributes count] > 2) {
        if ([[attributes objectAtIndex:2] isEqual:@"D"]) {
            _lazy = YES;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_propertyName release]; _propertyName = nil;
    [_propertyType release]; _propertyType = nil;
    [_variableName release]; _variableName = nil;
    [super dealloc];
}

@end
