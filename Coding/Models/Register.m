//
//  Register.m
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Register.h"

@implementation Register

- (NSDictionary *)toParams{
    return @{@"email" : self.email,
             @"global_key" : self.global_key,
             @"j_captcha" : _j_captcha ? _j_captcha: @"",
             @"channel" : [Register channel]};
}

+ (NSString *)channel{
    return @"coding-ios";
}

@end
