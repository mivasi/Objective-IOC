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

#import "IOCSingletonCacheTests.h"

@implementation IOCSingletonCacheTests

- (void)setUp {
    [super setUp];
    _cache = [[MVIOCSingletonCache alloc] init];
}

- (void)tearDown {
    [_cache release]; _cache = nil;
    [super tearDown];
}

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

#else                           // all code under test must be linked into the Unit Test bundle

- (void)testCreateAnotherCacheWhichIsShared {
    MVIOCSingletonCache *anotherCache = [[[MVIOCSingletonCache alloc] init] autorelease];
    STAssertTrue(_cache == anotherCache, @"MVIOCSingleton has not just one instance per app");
}

- (void)testAddAndGetSomeFromCache {
    [_cache storeInstance:self withKey:@"Something"];
    id fromCache = [_cache getInstanceWithKey:@"Something"];
    STAssertTrue(self == fromCache, @"Added instance to cache is not same as returned from cache");
}

#endif


@end
