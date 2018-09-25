//
//  OTPAuthClock.h
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTPAuthClock : UIView

//period:OTP密码更新周期
- (instancetype)initWithFrame:(CGRect)frame period:(NSTimeInterval)period;
//停止定时器
- (void)invalidate;

@end
