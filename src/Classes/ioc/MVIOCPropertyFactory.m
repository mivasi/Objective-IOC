//
//  MVIOCPropertyFactory.m
//  IOC
//
//  Created by Michal Vašíček on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCPropertyFactory.h"
#import "MVIOCProperty.h"
#import "MVIOCContainer.h"
#import <objc/runtime.h>

@interface MVIOCPropertyFactory ()

- (NSArray *)getClassPropertiesForInject:(Class)clazz;

@end


@implementation MVIOCPropertyFactory

- (id)createInstanceFor:(Class)clazz {
    id instance = class_createInstance(clazz, 0);
    instance = [instance init];
    
    NSArray *dependencies = [self getClassPropertiesForInject:clazz];    
    
    for (MVIOCProperty *property in dependencies) {
        [instance setValue:[_container getComponent:property.type] forKey:property.name];
    }
    
    return instance;
}

- (void)setContainer:(MVIOCContainer *)container {
    _container = container;
}

#pragma mark Private methods

- (NSArray *)getClassPropertiesForInject:(Class)clazz {
    unsigned int propertiesCount;
    objc_property_t *properties = class_copyPropertyList(clazz, &propertiesCount);
    
    NSMutableArray *propertiesAttributes = [NSMutableArray array];
    for(int i = 0; i < propertiesCount; i++) {
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        [propertiesAttributes addObject:propertyAttributes];
    }
    
    NSMutableArray *dependecies = [NSMutableArray array];
    for (NSString *propertyAttributes in propertiesAttributes) {
        //T@"ClassToIntrospect",&,N,V_ctiProp
        NSArray *attributes = [propertyAttributes componentsSeparatedByString:@","];
        if ([attributes count] == 4) {
            NSString *variableName = [[attributes objectAtIndex:3] substringFromIndex:1];
            if ([variableName hasPrefix:@"inj"]) {
                NSString *variableTypePart = [attributes objectAtIndex:0];
                NSString *variableType;
                if ([variableTypePart characterAtIndex:3] == '<') {
                    variableType = [[variableTypePart substringFromIndex:4] substringToIndex:([variableTypePart length] - 4 - 2)];
                } else {
                    variableType = [[variableTypePart substringFromIndex:3] substringToIndex:([variableTypePart length] - 3 - 1)];
                }
                MVIOCProperty *property = [[MVIOCProperty alloc] initWithName:variableName type:variableType];
                [dependecies addObject:property];
                [property release];
            }
        }
    }
    return dependecies;
}


@end
