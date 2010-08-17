//
//  MVIOCFactoryInjectionType.h
//  IOC
//
//  Created by Michal Vašíček on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVIOCInjectionType.h"

#define MVIOCFactoryInjectionTypeDefault [[[MVIOCFactoryInjectionType alloc] initWithFactoryInjectionType:[[[MVIOCPropertyInjectionType alloc] init] autorelease]] autorelease]

@class MVIOCInjectionType;

@interface MVIOCFactoryInjectionType : NSObject <MVIOCInjectionType> {
    id<MVIOCInjectionType> _factoryInjectionType;
    MVIOCContainer *_container;
}

@property(nonatomic, retain) id<MVIOCInjectionType> factoryInjectionType;

- (id)initWithFactoryInjectionType:(id<MVIOCInjectionType>)injectionType;

@end
