//
//  MVIOCContainer.m
//  IOC
//
//  Created by Michal Vašíček on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCContainer.h"
#import "MVIOCProperty.h"

#import "MVIOCInjectionType.h"
#import "MVIOCPropertyInjectionType.h"

#import "MVIOCCache.h"
#import "MVIOCSingletonCache.h"
#import <objc/runtime.h>

BOOL MVIOCContainerIsProtocol(id object) {
    return [NSStringFromClass(object_getClass(object)) isEqual:@"Protocol"];
}

@interface MVIOCContainer ()

@property(nonatomic, retain) NSMutableDictionary *components;
@property(nonatomic, retain) NSMutableDictionary *componentsAsInstances;

@property(nonatomic, retain) NSMutableDictionary *componentsFactories;
@property(nonatomic, retain) NSMutableDictionary *componentsCaches;
@property(nonatomic, retain) NSMutableDictionary *componentsDeps;
@property(nonatomic, retain) NSMutableDictionary *componentsInitSelectors;
@property(nonatomic, retain) NSMutableDictionary *componentsInitParams;

@end

@implementation MVIOCContainer

@synthesize components = _components;
@synthesize componentsAsInstances = _componentsAsInstances;
@synthesize componentsFactories = _componentsFactories;
@synthesize componentsCaches = _componentsCaches;
@synthesize componentsDeps = _componentsDeps;
@synthesize componentsInitSelectors = _componentsInitSelectors;
@synthesize componentsInitParams = _componentsInitParams;

- (id)init {
    if (self = [super init]) {
        self.components = [NSMutableDictionary dictionary];
        self.componentsFactories = [NSMutableDictionary dictionary];
        self.componentsCaches = [NSMutableDictionary dictionary];
        self.componentsDeps = [NSMutableDictionary dictionary];
        self.componentsAsInstances = [NSMutableDictionary dictionary];
        self.componentsInitSelectors = [NSMutableDictionary dictionary];
        self.componentsInitParams = [NSMutableDictionary dictionary];        
    }
    return self;
}

- (void)dealloc {
    self.components = nil;
    self.componentsAsInstances = nil;
    self.componentsFactories = nil;
    self.componentsCaches = nil;
    self.componentsDeps = nil;
    self.componentsInitSelectors = [NSMutableDictionary dictionary];
    self.componentsInitParams = [NSMutableDictionary dictionary];        
    
    [_factory release]; _factory = nil;
    [_cache release]; _cache = nil;
    [super dealloc];
}

- (void)addComponent:(id)component {
    [self addComponent:component representing:component];
}

- (void)addComponent:(id)component representing:(id)representing {
    NSString *key;
    
    if (MVIOCContainerIsProtocol(representing)) {
        key = NSStringFromProtocol(representing);
    } else if ([representing isKindOfClass:[NSString class]]) {
        key = representing;
    } else if ((Class)representing == [representing class]){
        key = NSStringFromClass(representing);
    } else {
        key = NSStringFromClass([representing class]);
    }

    if ((Class)component != [component class]) {
        [self.componentsAsInstances setObject:component forKey:key];
        return;
    }
    
    [self.components setObject:component forKey:key];
    if (_withInjectionType != nil) {
        [self.componentsFactories setObject:_withInjectionType forKey:key];
        _withInjectionType = nil;
    }
    if (_withCache != nil) {
        [self.componentsCaches setObject:_withCache forKey:key];
        _withCache = nil;
    }
    if (_withDeps != nil) {
        [self.componentsDeps setObject:_withDeps forKey:key];
    }
    if (_withInitSelector != nil) {
        [self.componentsInitSelectors setObject:[NSValue valueWithPointer:_withInitSelector] forKey:key];
    }
    if (_withInitParams != nil) {
        [self.componentsInitParams setObject:_withInitParams forKey:key];
    }
}

- (id)getComponent:(id)component {
    NSString *componentName;
    
    if (MVIOCContainerIsProtocol(component)) {
        componentName = NSStringFromProtocol(component);
    } else if ([component isKindOfClass:[NSString class]]) {
        componentName = component;
    } else {
        componentName = NSStringFromClass(component);
    }
    
    Class componentClass = [self.components objectForKey:componentName];
    if (componentClass == nil) {
        id instance = [self.componentsAsInstances objectForKey:componentName];
        if (instance == nil) {
            NSLog(@"Component named %@ not found.", componentName);
        }
        return instance;
    }
    
    id<MVIOCInjectionType> componentFactory = [self.componentsFactories objectForKey:componentName];
    
    if (componentFactory == nil) {
        componentFactory = self.injectionType;
    }

    id<MVIOCCache> componentCache = [self.componentsCaches objectForKey:componentName];
    
    if (componentCache != nil) {
        id cachedInstance = [componentCache getInstanceWithKey:componentName];
        if (cachedInstance != nil) {
            return cachedInstance;
        }
    }
    
    
    id instance;
    
    id deps = [self.componentsDeps objectForKey:componentName];
    SEL initSelector = [[self.componentsInitSelectors objectForKey:componentName] pointerValue];
    NSArray *initParams = [self.componentsInitParams objectForKey:componentName];

    instance = [componentFactory createInstanceFor:componentClass withDeps:deps initSelector:initSelector initParams:initParams];
    
    if (componentCache != nil) {
        [componentCache storeInstance:instance withKey:componentName];
    }
    
    return instance;
}

#pragma mark Setup default container behaviour

- (void)setInjectionType:(id <MVIOCInjectionType>)factory {
    [_factory autorelease];
    _factory = [factory retain];
    if ([_factory respondsToSelector:@selector(setContainer:)]) {
        [_factory setContainer:self];
    }
}

- (id<MVIOCInjectionType>)injectionType {
    if (_factory == nil) {
        [self setInjectionType:[[[MVIOCPropertyInjectionType alloc] init] autorelease]];
    }
    return _factory;
}

- (void)setCache:(id<MVIOCCache>)cache {
    [_cache autorelease];
    _cache = [cache retain];
}

- (id<MVIOCCache>)cache {
    if (_cache == nil) {
        [self setCache:[[[MVIOCSingletonCache alloc] init] autorelease]];
    }
    return _cache;
}

#pragma mark Fluent setup methods for adding component

- (id)withInjectionType:(id<MVIOCInjectionType>)injectionType {
    _withInjectionType = injectionType;
    if ([injectionType respondsToSelector:@selector(setContainer:)]) {
        [injectionType setContainer:self];
    }
    return self;
}

- (id)withCache:(id<MVIOCCache>)cache {
    _withCache = cache;
    return self;
}

- (id)withCache {
    _withCache = self.cache;
    return self;
}

- (id)withDeps:(id)firstDep, ... {
    NSMutableArray *deps = [NSMutableArray array];
    id eachDep;
    va_list argumentList;
    if(firstDep) {
        [deps addObject: firstDep];
        va_start(argumentList, firstDep);
        while (eachDep = va_arg(argumentList, id))
            [deps addObject: eachDep];
        va_end(argumentList);
    }
    
    _withDeps = deps;
    
    return self;
}

- (id)withDepsDictionary:(NSDictionary *)dictionary {
    _withDeps = dictionary;
    return self;
}

- (id)withInitSelector:(SEL)selector params:(id)object, ... {
    _withInitSelector = selector;
    NSMutableArray *params = [NSMutableArray array];
    id eachParam;
    va_list argumentList;
    if (object) {
        [params addObject:object];
        va_start(argumentList, object);
        while (eachParam = va_arg(argumentList, id)) {
            [params addObject:eachParam];
        }
        va_end(argumentList);
    }
    
    _withInitParams = params;
    return self;
}

#pragma mark Private methods


@end
