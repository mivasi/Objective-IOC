// 
// Copyright 2010 MICHAL VASICEK
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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

@interface MVTestCustomInitClass : NSObject {
    id _object;
}

@property(nonatomic, retain) id object;

- (id)initWithObject:(id)object;

@end