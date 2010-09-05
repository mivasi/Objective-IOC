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

#import "MVIOCPropertyInjectionType.h"
#import "MVIOCProperty.h"
#import "MVIOCContainer.h"
#import <objc/runtime.h>

@class MVTestComposite;

static NSString * const containerKey = @"container";
static NSString * const cacheKey = @"cache";
static NSString * const explicitDependeciesKey = @"explicitDependecies";


id MVIOCPropertyInjectionTypeGetLazyComponent(id obj, SEL cmd) {
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

void MVIOCPropertyInjectionTypeTidyUp(id obj, SEL cmd) {
    objc_setAssociatedObject(obj, cacheKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(obj, explicitDependeciesKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_msgSend(obj, @selector(originalDealloc));
}

@interface MVIOCPropertyInjectionType ()

- (NSArray *)getClassPropertiesForInject:(Class)clazz;

@end


@implementation MVIOCPropertyInjectionType

- (id)createInstanceFor:(Class)clazz withDeps:(id)deps initSelector:(SEL)initSelector initParams:(NSArray*)initParams {
    NSMutableDictionary *depsDictionary = [(NSDictionary *)deps mutableCopy];
    
    id instance = class_createInstance(clazz, 0);
    
    if (initSelector) {
        NSMethodSignature *sig = [instance methodSignatureForSelector:initSelector];
        NSInvocation *initInvocation = [NSInvocation invocationWithMethodSignature:sig];
        [initInvocation setTarget:instance];
        [initInvocation setSelector:initSelector];
        int i = 2;
        for (id arg in initParams) {
            [initInvocation setArgument:&arg atIndex:i];
            i++;
        }
        [initInvocation invoke];
        id anotherInstance;
        [initInvocation getReturnValue:&anotherInstance];
        instance = anotherInstance;
    } else {
        instance = [instance init];        
    }
    
    NSArray *autoWiredDependencies = [self getClassPropertiesForInject:clazz];    
    
    for (MVIOCProperty *property in autoWiredDependencies) {
        if (property.lazy) {
            if (![instance respondsToSelector:NSSelectorFromString(property.name)]) {
                class_addMethod(clazz, NSSelectorFromString(property.name), (IMP) MVIOCPropertyInjectionTypeGetLazyComponent, "@@:");                
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
                class_replaceMethod(clazz, @selector(dealloc), (IMP)MVIOCPropertyInjectionTypeTidyUp, "v@:");
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
    
    return [instance autorelease];
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
        } else if ([property.variableName hasPrefix:@"inj"]) {
            [dependecies addObject:property];
        }
        [property release];
    }
    free(properties);
    return dependecies;
}

@end
