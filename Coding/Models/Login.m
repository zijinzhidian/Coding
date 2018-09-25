//
//  Login.m
//  Coding
//
//  Created by apple on 2018/4/19.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Login.h"
#import "XGPush.h"
#import "AppDelegate.h"

#define kLoginStatus @"login_status"
#define kLoginUserDict @"user_dict"
#define kLoginPreUserEmail @"pre_user_email"
#define kLoginDataListPath @"login_data_list_path.plist"
#define kLoginPasswordKey(_key_) [NSString stringWithFormat:@"password|%@", _key_]

static User *curLoginUser;

@implementation Login

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.remember_me = @(YES);
    }
    return self;
}

#pragma mark - Public Actions
//保存当前用户的登陆帐号
+ (void)setPreUserEmail:(NSString *)emailStr {
    if (emailStr.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:emailStr forKey:kLoginPreUserEmail];
    [defaults synchronize];
}

//获取用户手机号码/邮箱/个性后缀
+ (NSString *)preUserEmail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginPreUserEmail];
}

//获取普通登陆的Path
- (NSString *)toPath {
    return @"api/v2/account/login";
}

//获取普通登陆的参数
- (NSDictionary *)toParams {
    NSMutableDictionary *params = @{@"account": self.email,
                                    @"password" : [self.password sha1Str],
                                    @"remember_me" : self.remember_me ? @"true" : @"false",}.mutableCopy;
    if (self.j_captcha.length > 0) {
        params[@"j_captcha"] = self.j_captcha;
    }
    //保存一下登陆密码
    [Login p_setPassword:self.password forAccount:self.email.lowercaseString];
    return params;
}

//获取登陆提示信息
- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha {
    if (!_email || _email.length <= 0) {
        return @"请填写「手机号码／电子邮箱／个性后缀」";
    }
    if (!_password || _password.length <= 0) {
        return @"请填写密码";
    }
    if (needCaptcha && (!_j_captcha || _j_captcha.length <= 0)) {
        return @"请填写验证码";
    }
    return nil;
}

//登陆
+ (void)doLogin:(NSDictionary *)loginData {
    if (loginData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(YES) forKey:kLoginStatus];        //登陆状态
        [defaults setObject:loginData forKey:kLoginUserDict];   //用户数据
        curLoginUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        [defaults synchronize];
        //保存用户信息(邮箱／手机号码／个性后缀)
        [self saveLogonData:loginData];
        //注册信鸽推送
        
    } else {
        [Login doLogout];
    }
}

//退出登陆
+ (void)doLogout {
    //清除角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //设置登陆状态为NO
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(NO) forKey:kLoginStatus];
    [defaults synchronize];
    //删掉coding的cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.domain hasPrefix:@".coding.net"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
        }
    }];
    //注销信鸽推送
    
}

//获取登陆状态
+ (BOOL)isLogin {
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if (loginStatus.boolValue && [Login curLoginUser]) {
        User *loginUser = [Login curLoginUser];
        if (loginUser.status && loginUser.status.integerValue == 0) {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

//获取当前用户的数据
+ (User *)curLoginUser {
    if (!curLoginUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict];
        curLoginUser = loginData ? [NSObject objectOfClass:@"User" fromJSON:loginData] : nil;
    }
    return curLoginUser;
}

//设置信鸽推送账户
+ (void)setXGAccountWithCurUser {
    if ([self isLogin]) {
        User *user = [Login curLoginUser];
        if (user && user.global_key.length > 0) {
            //绑定账户
            [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:user.global_key type:XGPushTokenBindTypeAccount];
            //开始信鸽推送
            [(AppDelegate *)[UIApplication sharedApplication].delegate registerPush];
        } else {
            //解决绑定
            [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:user.global_key type:XGPushTokenBindTypeAccount];
            //注销信鸽推送
            [[XGPush defaultManager] stopXGNotification];
        }
    }
}

#pragma mark - Privite Actions
//获取保存用户登陆信息的路径
+ (NSString *)loginDataListPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:kLoginDataListPath];
}

//获取用户登陆信息
+ (NSMutableDictionary *)readLoginDataList {
    NSMutableDictionary *loginDataList = [NSMutableDictionary dictionaryWithContentsOfFile:[self loginDataListPath]];
    if (!loginDataList) {
        loginDataList = [NSMutableDictionary dictionary];
    }
    return loginDataList;
}

//保存用户信息
+ (BOOL)saveLogonData:(NSDictionary *)loginData {
    BOOL saved = NO;
    if (loginData) {
        NSMutableDictionary *loginDataList = [self readLoginDataList];
        User *curUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        if (curUser.global_key.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.global_key];
            saved = YES;
        }
        if (curUser.email.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.email];
            saved = YES;
        }
        if (curUser.phone.length > 0) {
            [loginDataList setObject:loginData forKey:curUser.phone];
            saved = YES;
        }
        if (saved) {
            saved = [loginDataList writeToFile:[self loginDataListPath] atomically:YES];
        }
    }
    return saved;
}

//保存登陆密码
+ (void)p_setPassword:(NSString *)password forAccount:(NSString *)account {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:password forKey:kLoginPasswordKey(account)];
    [defaults synchronize];
}

@end
