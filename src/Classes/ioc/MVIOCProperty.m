//
//  MVIOCProperty.m
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCProperty.h"

@implementation MVIOCProperty

@synthesize name = _propertyName;
@synthesize type = _propertyType;

- (id)initWithName:(NSString *)name type:(id)type {
    if (self = [super init]) {
        _propertyName = [name retain];
        _propertyType = [type retain];
    }
    return self;
}

- (void)dealloc {
    [_propertyName release]; _propertyName = nil;
    [_propertyType release]; _propertyType = nil;
    [super dealloc];
}

@end
