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

@class MVTestComposite;

static NSString * const containerKey = @"container";
static NSString * const cacheKey = @"cache";

id MVIOCPropertyFactoryGetLazyComponent(id obj, SEL cmd) {
    MVIOCContainer *container = objc_getAssociatedObject(obj, containerKey);
    NSMutableDictionary *cache = objc_getAssociatedObject(obj, cacheKey);
    if ([cache objectForKey:NSStringFromSelector(cmd)] != nil) {
        return [cache objectForKey:NSStringFromSelector(cmd)];
    }
    objc_property_t objcProperty = class_getProperty([obj class], [NSStringFromSelector(cmd) cStringUsingEncoding:NSUTF8StringEncoding]);
    
    MVIOCProperty *property = [[MVIOCProperty alloc] initWithObjCProperty:objcProperty];
    
    id instance = [container getComponent:property.type];
    if (instance != nil) {
        [cache setObject:instance forKey:NSStringFromSelector(cmd)];        
    }
    
    [property release];
    
    return instance;
}

void MVIOCPropertyFactoryTidyUp(id obj, SEL cmd) {
    objc_setAssociatedObject(obj, cacheKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_msgSend(obj, @selector(originalDealloc));
}

@interface MVIOCPropertyFactory ()

- (NSArray *)getClassPropertiesForInject:(Class)clazz;

@end


@implementation MVIOCPropertyFactory

- (id)createInstanceFor:(Class)clazz {
    id instance = class_createInstance(clazz, 0);
    instance = [instance init];
    
    NSArray *dependencies = [self getClassPropertiesForInject:clazz];    
    
    for (MVIOCProperty *property in dependencies) {
        if (property.lazy) {
            if (![instance respondsToSelector:NSSelectorFromString(property.name)]) {
                class_addMethod(clazz, NSSelectorFromString(property.name), (IMP) MVIOCPropertyFactoryGetLazyComponent, "@@:");                
            }
            
            if (!objc_getAssociatedObject(instance, cacheKey)) {
                objc_setAssociatedObject(instance, containerKey, _container, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(instance, cacheKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            
            if (![instance respondsToSelector:@selector(originalDealloc)]) {
                IMP deallocImpl = class_getMethodImplementation(clazz, @selector(dealloc));
                class_addMethod(clazz, @selector(originalDealloc), deallocImpl, "v");
                class_replaceMethod(clazz, @selector(dealloc), (IMP)MVIOCPropertyFactoryTidyUp, "v@:");
            }
        } else {
            [instance setValue:[_container getComponent:property.type] forKey:property.name];            
        }
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
    
    NSMutableArray *dependecies = [NSMutableArray array];

    for(int i = 0; i < propertiesCount; i++) {
        MVIOCProperty *property = [[MVIOCProperty alloc] initWithObjCProperty:properties[i]];
        if(property.lazy) {
            [dependecies addObject:property];
            [property release];
        } else if ([property.variableName hasPrefix:@"inj"]) {
            [dependecies addObject:property];
            [property release];                
        }
    }
    
    return dependecies;
}

@end
