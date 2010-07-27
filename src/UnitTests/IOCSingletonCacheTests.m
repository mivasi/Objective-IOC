//
//  IOCSingletonCacheTests.m
//  IOC
//
//  Created by Michal Vašíček on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
