//
//  MVIOCPropertyFactory.h
//  IOC
//
//  Created by Michal Vašíček on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVIOCFactory.h"

@class MVIOCContainer;

@interface MVIOCPropertyFactory : NSObject <MVIOCFactory> {
    MVIOCContainer *_container;
    
}

@end
