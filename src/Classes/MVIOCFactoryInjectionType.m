//
//  MVIOCFactoryInjectionType.m
//  IOC
//
//  Created by Michal Vašíček on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCFactoryInjectionType.h"
#import <objc/runtime.h>



@implementation MVIOCFactoryInjectionType

- (void)dealloc {
    [_factoryInjectionType release];_factoryInjectionType = nil;
    [super dealloc];
}

- (void)setContainer:(MVIOCContainer *)container {
    _container = container;
    if ([self.factoryInjectionType respondsToSelector:@selector(setContainer:)]) {
        [self.factoryInjectionType setContainer:container];
    }
}

- (void)setFactoryInjectionType:(id<MVIOCInjectionType>)injectionType {
    [_factoryInjectionType autorelease];
    _factoryInjectionType = [injectionType retain];
    if (_container != nil) {
        if ([self.factoryInjectionType respondsToSelector:@selector(setContainer:)]) {
            [self.factoryInjectionType setContainer:_container];
        }        
    }
}

- (id<MVIOCInjectionType>)factoryInjectionType {
    return _factoryInjectionType;
}

- (id)createInstanceFor:(Class)clazz withDeps:(id)deps initSelector:(SEL)initSelector initParams:(NSArray *)initParams {
    id factoryInstance = [self.factoryInjectionType createInstanceFor:clazz withDeps:deps initSelector:initSelector initParams:initParams];
    return [factoryInstance performSelector:@selector(createInstance)];
}


@end
