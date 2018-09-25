//
//  Register.h
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Register : NSObject

@property(nonatomic,copy)NSString *email, *global_key, *j_captcha, *phone, *code, *password, *confirm_password;

+ (NSString *)channel;

- (NSDictionary *)toParams;

@end
