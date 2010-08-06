//
//  TestClasses.h
//  IOC
//
//  Created by Michal Vašíček on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MVTestComposite;
@protocol MVTestProtocol;

@interface MVTestCompositor : NSObject {
    MVTestComposite *injComposite;
    id<MVTestProtocol> manualComposite;
}

@property(nonatomic, retain) MVTestComposite *composite;
@property(nonatomic, retain) id<MVTestProtocol> manualComposite;
@property(nonatomic, retain) id<MVTestProtocol> *lazyComposite;

@end

@interface MVTestLazyCompositor : NSObject {
    
}
@property(nonatomic, retain) MVTestComposite *composite;
@end


@interface MVTestComposite : NSObject {

}
@end

@protocol MVTestProtocol <NSObject>

@end

@interface MVTestProtocolImplementation : NSObject <MVTestProtocol>

@end

@interface MVTestProtocolCompositor : NSObject {
    id<MVTestProtocol> injComposite;
}

@property(nonatomic, retain) id<MVTestProtocol> composite;

@end