//
//  TestClasses.m
//  IOC
//
//  Created by Michal Vašíček on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestClasses.h"


@implementation MVTestCompositor
@synthesize composite = injComposite;
@end

@implementation MVTestLazyCompositor 

@dynamic composite;

- (void)dealloc {
    NSLog(@"dealloc");
    [super dealloc];
}
@end


@implementation MVTestComposite

@end