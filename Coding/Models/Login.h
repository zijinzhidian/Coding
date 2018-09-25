//
//  Login.h
//  Coding
//
//  Created by apple on 2018/4/19.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Login : NSObject

@property(nonatomic,copy)NSString *email, *password, *j_captcha;
@property(nonatomic,strong)NSNumber *remember_me;

//获取用户手机号码/邮箱/个性后缀
+ (NSString *)preUserEmail;
//获取登陆提示信息
- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha;
//获取当前用户的数据
+ (User *)curLoginUser;
//获取用户登陆信息
+ (NSMutableDictionary *)readLoginDataList;
//获取登陆状态
+ (BOOL)isLogin;
//获取普通登陆的Path
- (NSString *)toPath;
//获取普通登陆的参数
- (NSDictionary *)toParams;

//保存当前用户的登陆帐号
+ (void)setPreUserEmail:(NSString *)emailStr;

//登陆
+ (void) doLogin:(NSDictionary *)loginData;
//退出登陆
+ (void) doLogout;

//设置信鸽推送账户
+ (void)setXGAccountWithCurUser;

@end
