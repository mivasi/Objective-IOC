//
//  MVIOCProperty.h
//  IOC
//
//  Created by Michal Vašíček on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MVIOCProperty : NSObject {
    NSString *_propertyName;
    id _propertyType;
}

@property(readonly) NSString *name;
@property(readonly) id type;

- (id)initWithName:(NSString *)name type:(id)type;

@end
