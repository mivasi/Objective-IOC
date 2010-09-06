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

#import "MVIOCControllerActor.h"
#import <objc/runtime.h>

static NSString * const owningControllerKey = @"owningController";

void MVIOCControllerActorDidAddSubView(UIView *view, SEL cmd, UIView *subView) {
    Class clazz = [subView class];
    if (![subView respondsToSelector:@selector(owningController:)]) {        
        class_addMethod(clazz, @selector(owningController), (IMP)MVIOCControllerActorOwningController, "@@:");
    }
    
    if (class_getMethodImplementation(clazz, @selector(didAddSubview:)) != (IMP)MVIOCControllerActorDidAddSubView) {
        class_replaceMethod(clazz, @selector(didAddSubview:), (IMP)MVIOCControllerActorDidAddSubView, "v@:@");        
    }    
}

UIViewController* MVIOCControllerActorOwningController (UIView *obj, SEL cmd) {
    id owningController = objc_getAssociatedObject(obj, owningControllerKey);
    if (owningController != nil) {
        return owningController;
    }
    return owningController = [obj.superview performSelector:@selector(owningController)];
}

void MVIOCControllerActorSetView(id obj, SEL cmd, UIView * view) {
    Class clazz = [view class];
    
    if (![view respondsToSelector:@selector(owningController:)]) {        
        class_addMethod(clazz, @selector(owningController), (IMP)MVIOCControllerActorOwningController, "@@:");
    }
    if (class_getMethodImplementation(clazz, @selector(didAddSubview:)) != (IMP)MVIOCControllerActorDidAddSubView) {
        class_replaceMethod(clazz, @selector(didAddSubview:), (IMP)MVIOCControllerActorDidAddSubView, "v@:@");        
    }  
    objc_setAssociatedObject(view, owningControllerKey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [obj performSelector:@selector(originalSetView:) withObject:view];
}

@implementation MVIOCControllerActor

- (void)makeActOnInstance:(id)instance {
    if (![instance respondsToSelector:@selector(originalSetView:)]) {        
        Class clazz = [instance class];
        IMP setViewImpl = class_getMethodImplementation(clazz, @selector(setView:));
        class_addMethod(clazz, @selector(originalSetView:), setViewImpl, "v@");
        class_replaceMethod(clazz, @selector(setView:), (IMP)MVIOCControllerActorSetView, "v@:@");
    }
}

@end
