//
//  MVIOCContainer.h
//  IOC
//
//  Created by Michal Vašíček on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MVIOCFactory;
@protocol MVIOCCache;

@interface MVIOCContainer : NSObject {
    id<MVIOCFactory> _factory;
    id<MVIOCCache> _cache;
    
    NSMutableDictionary *_components;
    NSMutableDictionary *_componentsAsInstances;
    NSMutableDictionary *_componentsFactories;
    NSMutableDictionary *_componentsCaches;
    NSMutableDictionary *_componentsLazyLoads;
    NSMutableDictionary *_componentsDeps;
    
    id<MVIOCFactory> _withFactory;
    id<MVIOCCache> _withCache;
    id _withDeps;
}

@property(nonatomic, retain) id<MVIOCFactory> factory;
@property(nonatomic, retain) id<MVIOCCache> cache;

- (void)addComponent:(id)component;

/**
 Add component which will represent some role in your system
 */
- (void)addComponent:(id)component representing:(id)representing;
- (id)getComponent:(id)component;

#pragma mark Setup default container behaviour
- (void)setFactory:(id<MVIOCFactory>)factory;

#pragma mark Fluent setup methods for adding component
- (id)withFactory:(id<MVIOCFactory>)factory;
- (id)withCache:(id<MVIOCCache>)cache;
- (id)withCache;
- (id)withDeps:(id)firstDep, ...;
- (id)withDepsDictionary:(NSDictionary *)dictionary;

@end