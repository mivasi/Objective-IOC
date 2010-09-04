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

#import "MVIOCFactoryInjectionType.h"
#import <objc/runtime.h>



@implementation MVIOCFactoryInjectionType

- (id)initWithFactoryInjectionType:(id<MVIOCInjectionType>)injectionType {
    if (self = [super init]) {
        self.factoryInjectionType = injectionType;
    }
    
    return self;
}

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
