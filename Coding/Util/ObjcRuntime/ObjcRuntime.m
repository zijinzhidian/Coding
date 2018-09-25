//
//  ObjcRuntime.m
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ObjcRuntime.h"

void Swizzle(Class c, SEL origSEL, SEL newSEL) {
    //实例方法
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
    //类方法
    if (!origMethod) {
        origMethod = class_getClassMethod(c, origSEL);
        if (!origMethod) {
            return;
        }
        newMethod = class_getClassMethod(c, newSEL);
        if (!newMethod) {
            return;
        }
    } else {
        newMethod = class_getInstanceMethod(c, newSEL);
        if (!newMethod) {
            return;
        }
    }
    
    //自身已经有了就添加不成功,直接替代即可
    if (class_addMethod(c, origSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}
