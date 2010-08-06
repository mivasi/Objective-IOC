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
static NSString * const explicitDependeciesKey = @"explicitDependecies";


id MVIOCPropertyFactoryGetLazyComponent(id obj, SEL cmd) {
    MVIOCContainer *container = objc_getAssociatedObject(obj, containerKey);
    NSMutableDictionary *cache = objc_getAssociatedObject(obj, cacheKey);
    NSMutableDictionary *explicitDependecies = objc_getAssociatedObject(obj, explicitDependeciesKey);
    
    if ([cache objectForKey:NSStringFromSelector(cmd)] != nil) {
        return [cache objectForKey:NSStringFromSelector(cmd)];
    }
    objc_property_t objcProperty = class_getProperty([obj class], [NSStringFromSelector(cmd) cStringUsingEncoding:NSUTF8StringEncoding]);
    
    MVIOCProperty *property = [[MVIOCProperty alloc] initWithObjCProperty:objcProperty];
    
    id componentKey = [explicitDependecies objectForKey:property.name];
    if (componentKey == nil) {
        componentKey = property.type;
    }
    
    id instance = [container getComponent:componentKey];
    if (instance != nil) {
        [cache setObject:instance forKey:NSStringFromSelector(cmd)];        
    }
    
    [property release];
    
    return instance;
}

void MVIOCPropertyFactoryTidyUp(id obj, SEL cmd) {
    objc_setAssociatedObject(obj, cacheKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(obj, explicitDependeciesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_msgSend(obj, @selector(originalDealloc));
}

@interface MVIOCPropertyFactory ()

- (NSArray *)getClassPropertiesForInject:(Class)clazz;

@end


@implementation MVIOCPropertyFactory

- (id)createInstanceFor:(Class)clazz {
    return [self createInstanceFor:clazz withDeps:nil];
}

- (id)createInstanceFor:(Class)clazz withDeps:(id)deps {
    NSMutableDictionary *depsDictionary = [(NSDictionary *)deps mutableCopy];
    
    id instance = class_createInstance(clazz, 0);
    instance = [instance init];
    
    NSArray *autoWiredDependencies = [self getClassPropertiesForInject:clazz];    
    
    for (MVIOCProperty *property in autoWiredDependencies) {
        if (property.lazy) {
            if (![instance respondsToSelector:NSSelectorFromString(property.name)]) {
                class_addMethod(clazz, NSSelectorFromString(property.name), (IMP) MVIOCPropertyFactoryGetLazyComponent, "@@:");                
            }
            
            if (!objc_getAssociatedObject(instance, cacheKey)) {
                objc_setAssociatedObject(instance, containerKey, _container, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(instance, cacheKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            
            id extDep = [depsDictionary objectForKey:property.name];
            if (extDep != nil) {
                NSMutableDictionary *explicitDependeciesDictionary = objc_getAssociatedObject(instance, explicitDependeciesKey);
                if (explicitDependeciesDictionary == nil) {
                    explicitDependeciesDictionary = [NSMutableDictionary dictionary];
                    objc_setAssociatedObject(instance, explicitDependeciesKey, explicitDependeciesDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
                [explicitDependeciesDictionary setObject:extDep forKey:property.name];
                [depsDictionary removeObjectForKey:property.name];
            }
            
            if (![instance respondsToSelector:@selector(originalDealloc)]) {
                IMP deallocImpl = class_getMethodImplementation(clazz, @selector(dealloc));
                class_addMethod(clazz, @selector(originalDealloc), deallocImpl, "v");
                class_replaceMethod(clazz, @selector(dealloc), (IMP)MVIOCPropertyFactoryTidyUp, "v@:");
            }
        } else {
            id extDep = [depsDictionary objectForKey:property.name];
            id componentKey;
            if (extDep != nil) {
                componentKey = [extDep copy];
                [depsDictionary removeObjectForKey:property.name];
            } else {
                componentKey = [property.type copy];
            }

            [instance setValue:[_container getComponent:componentKey] forKey:property.name];
            [componentKey release];
        }
    }
    
    for (NSString *propertyName in depsDictionary) {
        id componentKey = [depsDictionary objectForKey:propertyName];
        [instance setValue:[_container getComponent:componentKey] forKey:propertyName];
    }
    
    [depsDictionary release];
    
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
