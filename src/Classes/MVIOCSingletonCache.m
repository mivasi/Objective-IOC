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
