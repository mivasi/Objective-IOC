//
//  TestClasses.h
//  IOC
//
//  Created by Michal Vašíček on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVTestComposite;

@interface MVTestCompositor : NSObject {
    MVTestComposite *injComposite;
}
@property(nonatomic, retain) MVTestComposite *composite;
@end

@interface MVTestLazyCompositor : NSObject {
    
}
@property(nonatomic, retain) MVTestComposite *composite;
@end


@interface MVTestComposite : NSObject {
    MVTestComposite *injComposite;
}
@end