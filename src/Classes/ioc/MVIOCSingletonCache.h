//
//  MVIOCSingletonCache.h
//  IOC
//
//  Created by Michal Vašíček on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVIOCCache.h"

@interface MVIOCSingletonCache : NSObject <MVIOCCache> {
    NSMutableDictionary *_instances;
}

@end
