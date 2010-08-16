//
//  MVIOCInjectionType.h
//  IOC
//
//  Created by Michal Vašíček on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVIOCContainer.h"

@protocol MVIOCInjectionType <NSObject>

- (id)createInstanceFor:(Class)clazz withDeps:(id)deps initSelector:(SEL)initSelector initParams:(NSArray*)initParams;

@optional
- (void)setContainer:(MVIOCContainer *)container;

@end
