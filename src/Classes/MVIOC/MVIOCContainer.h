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

#import <Foundation/Foundation.h>

@protocol MVIOCInjectionType;
@protocol MVIOCCache;
@protocol MVIOCActor;

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
    NSMutableDictionary *_componentsActors;
    
    
    id<MVIOCInjectionType> _withInjectionType;
    id<MVIOCCache> _withCache;
    id _withDeps;
    SEL _withInitSelector;
    NSArray *_withInitParams;
    id<MVIOCActor> _actAs;
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
- (id)actAs:(id<MVIOCActor>)actor;
@end