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
@synthesize manualComposite;
@dynamic lazyComposite;
@end

@implementation MVTestLazyCompositor 

@dynamic composite;

- (void)dealloc {
    [super dealloc];
}
@end


@implementation MVTestComposite

@end

@implementation MVTestProtocolImplementation

@end

@implementation MVTestProtocolCompositor

@synthesize composite = injComposite;

@end
