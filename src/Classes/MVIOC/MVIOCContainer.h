//
//  MVIOCContainer.h
//  IOC
//
//  Created by Michal Vašíček on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MVIOCInjectionType;
@protocol MVIOCCache;

@interface MVIOCContainer : NSObject {
    id<MVIOCInjectionType> _factory;
    id<MVIOCCache> _cache;
    
    NSMutableDictionary *_components;
    NSMutableDictionary *_componentsAsInstances;
    
    NSMutableDictionary *_componentsFactories;
    NSMutableDictionary *_componentsCaches;
    NSMutableDictionary *_componentsDeps;
    NSMutableDictionary *_componentsInitSelectors;
    NSMutableDictionary *_componentsInitParams;
    
    id<MVIOCInjectionType> _withInjectionType;
    id<MVIOCCache> _withCache;
    id _withDeps;
    SEL _withInitSelector;
    NSArray *_withInitParams;
}

@property(nonatomic, retain) id<MVIOCInjectionType> injectionType;
@property(nonatomic, retain) id<MVIOCCache> cache;

- (void)addComponent:(id)component;

/**
 Add component which will represent some role in your system
 */
- (void)addComponent:(id)component representing:(id)representing;
- (id)getComponent:(id)component;

#pragma mark Setup default container behaviour
- (void)setInjectionType:(id<MVIOCInjectionType>)factory;

#pragma mark Fluent setup methods for adding component
- (id)withInjectionType:(id<MVIOCInjectionType>)injectionType;
- (id)withCache:(id<MVIOCCache>)cache;
- (id)withCache;
- (id)withDeps:(id)firstDep, ...;
- (id)withDepsDictionary:(NSDictionary *)dictionary;
- (id)withInitSelector:(SEL)selector params:(id)object, ...;

@end