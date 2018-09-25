//
//  OTPListViewController.h
//  Coding
//
//  Created by apple on 2018/4/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 1.OTP:一种密码算法
 2.OTP全称叫One-Time Password,也称动态口令,根据专门的算法每隔60秒生成一个与时间相关的、不可预测的随机数字组合,每个口令只能使用一次,每天可以产生1440个密码
 3.动态口令手机令牌是推出了最新的身份认证终端，DKEY动态口令手机令牌是一种基于挑战/应答方式的手机客户端软件，在该软件上输入服务端下发的挑战码，手机软件上生成一个6位的随机数字，这个口令只能使用一次，可以充分的保证登录认证的安全，在生成口令的过程中，不会产生任何通信，保证密码不会在通信信道中被截取，也不会产生任何通信费用，手机作为动态口令生成的载体，欠费和无信号对其不产生任何影响
 */

/*
 使用SAMKeychain框架前需要导入Security.framework
 */

#import "BaseViewController.h"

#import "OTPAuthURL.h"
#import <SAMKeychain/SAMKeychain.h>

@interface OTPListViewController : BaseViewController

+ (NSString *)otpCodeWithGK:(NSString *)global_key;

@end
