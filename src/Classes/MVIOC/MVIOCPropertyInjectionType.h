//
//  MVIOCPropertyInjectionType.h
//  IOC
//
//  Created by Michal Vašíček on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVIOCInjectionType.h"

@class MVIOCContainer;

@interface MVIOCPropertyInjectionType : NSObject <MVIOCInjectionType> {
    MVIOCContainer *_container;
}

@end
