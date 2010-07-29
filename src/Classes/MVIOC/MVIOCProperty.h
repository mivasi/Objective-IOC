//
//  MVIOCProperty.h
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class MVIOCContainer;

@interface MVIOCProperty : NSObject {
    NSString *_propertyName;
    NSString *_variableName;
    id _propertyType;
    BOOL _lazy;
    
    objc_property_t _objcProperty;
}

@property(readonly) NSString *name;
@property(readonly) id type;
@property(readonly) BOOL lazy;
@property(readonly) NSString *variableName;

- (id)initWithObjCProperty:(objc_property_t)objcProperty;
@end
