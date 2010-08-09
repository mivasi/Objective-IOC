//
//  MVIOCCache.h
//  IOC
//
//  Created by Michal Vašíček on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MVIOCCache <NSObject>

- (void)storeInstance:(id)instance withKey:(NSString *)key;
- (id)getInstanceWithKey:(NSString *)key;

@end
