//
//  MVIOCContainer.m
//  IOC
//
//  Created by Michal Vašíček on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCContainer.h"
#import "MVIOCProperty.h"
#import "MVIOCFactory.h"
#import "MVIOCPropertyFactory.h"
#import "MVIOCCache.h"
#import <objc/runtime.h>

BOOL MVIOCContainerIsProtocol(id object) {
    return [NSStringFromClass(object_getClass(object)) isEqual:@"Protocol"];
}

@interface MVIOCContainer ()

@property(nonatomic, retain) NSMutableDictionary *components;
@property(nonatomic, retain) NSMutableDictionary *componentsFactories;
@property(nonatomic, retain) NSMutableDictionary *componentsCaches;

@end


@implementation MVIOCContainer

@synthesize components = _components;
@synthesize componentsFactories = _componentsFactories;
@synthesize componentsCaches = _componentsCaches;

- (id)init {
    if (self = [super init]) {
        self.components = [NSMutableDictionary dictionary];
        self.componentsFactories = [NSMutableDictionary dictionary];
        self.componentsCaches = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.components = nil;
    self.componentsFactories = nil;
    [_factory release]; _factory = nil;
    [super dealloc];
}

- (void)addComponent:(Class)component {
    [self addComponent:component representing:component];
}

- (void)addComponent:(Class)component representing:(id)representing {
    NSString *key;
    
    if (MVIOCContainerIsProtocol(representing)) {
        key = NSStringFromProtocol(representing);
    } else if ([representing isKindOfClass:[NSString class]]) {
        key = representing;
    } else {
        key = NSStringFromClass(representing);
    }
    
    [self.components setObject:component forKey:key];
    if (_withFactory != nil) {
        [self.componentsFactories setObject:_withFactory forKey:key];
        _withFactory = nil;
    }
    if (_withCache != nil) {
        [self.componentsCaches setObject:_withCache forKey:key];
        _withCache = nil;
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
    id<MVIOCFactory> componentFactory = [self.componentsFactories objectForKey:componentName];
    
    if (componentFactory == nil) {
        componentFactory = self.factory;
    }

    id<MVIOCCache> componentCache = [self.componentsCaches objectForKey:componentName];
    
    if (componentCache != nil) {
        id cachedInstance = [componentCache getInstanceWithKey:componentName];
        if (cachedInstance != nil) {
            return cachedInstance;
        }
    }
    
    id instance = [componentFactory createInstanceFor:componentClass];
    
    if (componentCache != nil) {
        [componentCache storeInstance:instance withKey:componentName];
    }
    
    return instance;
}

#pragma mark Setup default container behaviour

- (void)setFactory:(id <MVIOCFactory>)factory {
    [_factory autorelease];
    _factory = [factory retain];
    if ([_factory respondsToSelector:@selector(setContainer:)]) {
        [_factory setContainer:self];
    }
}

- (id<MVIOCFactory>)factory {
    if (_factory == nil) {
        [self setFactory:[[[MVIOCPropertyFactory alloc] init] autorelease]];
    }
    return _factory;
}

#pragma mark Fluent setup methods for adding component

- (id)withFactory:(id<MVIOCFactory>)factory {
    _withFactory = factory;
    if ([_factory respondsToSelector:@selector(setContainer:)]) {
        [_factory setContainer:self];
    }
    return self;
}

- (id)withCache:(id<MVIOCCache>)cache {
    _withCache = cache;
    return self;
}

#pragma mark Private methods


@end
