//
//  RegisterViewController.h
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"
#import "Register.h"

typedef NS_ENUM(NSUInteger, RegisterMethodType) {
    RegisterMethodEmail = 0,
    RegisterMethodPhone
};

@interface RegisterViewController : BaseViewController

+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType registerObj:(Register *)obj;

@end
