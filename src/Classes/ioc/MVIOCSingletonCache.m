//
//  MVIOCSingletonCache.m
//  IOC
//
//  Created by Michal Vašíček on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MVIOCSingletonCache.h"

static MVIOCSingletonCache const *_sharedInstance;

@implementation MVIOCSingletonCache

+ (void) initialize {
    if(_sharedInstance == nil) {
        _sharedInstance = [[MVIOCSingletonCache alloc] init];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    if (_sharedInstance == nil) {
        _sharedInstance = [super allocWithZone:zone];
    }
    return _sharedInstance;
}

- (id)init {
    if (_instances == nil) {
        _instances = [[NSMutableDictionary dictionary] retain];
    }
    return _sharedInstance;
}

- (void)storeInstance:(id)instance withKey:(NSString *)key{
    [_instances setObject:instance forKey:key];
}

- (id)getInstanceWithKey:(NSString *)key {
    return [_instances objectForKey:key];
}

-(NSString *)description {
    return [_instances description];
}

- (void)release {
    
}

- (id)retain {
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

@end
