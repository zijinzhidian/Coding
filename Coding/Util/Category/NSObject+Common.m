//
//  NSObject+Common.m
//  Coding
//
//  Created by apple on 2018/4/19.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#define kBaseURLStr @"https://coding.net/"

#define kHUDQueryViewTag 101
#define kPath_ResponseCache @"ResponseCache"    //缓存数据文件夹名称

#import "NSObject+Common.h"
#import "Login.h"
#import "AppDelegate.h"

@implementation NSObject (Common)

#pragma mark - Show And Hide
+ (void)showHudTipStr:(NSString *)tipStr {
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabel.text = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.0];
    }
}

- (BOOL)showError:(NSError *)error {
    //如果statusBar上面正在显示信息,则不再用Hud显示error
    if ([JDStatusBarNotification isVisible]) {
        return NO;
    }
    NSString *tipStr = [NSObject tipFromError:error];
    [NSObject showHudTipStr:tipStr];
    return YES;
}

+ (MBProgressHUD *)showHUDQueryStr:(NSString *)titleStr {
    titleStr = titleStr.length > 0 ? titleStr : @"正在获取数据...";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.tag = kHUDQueryViewTag;
    hud.label.font = [UIFont boldSystemFontOfSize:15];
    hud.label.text = titleStr;
    hud.margin = 10;
    return hud;
}

+ (NSUInteger)hideHUDQuery {
    __block NSUInteger count = 0;
    NSArray *huds = [MBProgressHUD allHUDsForView:kKeyWindow];
    [huds enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == kHUDQueryViewTag) {
            [obj removeFromSuperview];
            count++;
        }
    }];
    return count;
}

+ (NSString *)tipFromError:(NSError *)error {
    if (error && error.userInfo) {
        NSMutableString *tipStr = [NSMutableString string];
        if (error.userInfo[@"msg"]) {
            NSArray *msgArray = [error.userInfo[@"msg"] allValues];
            for (int i = 0; i < msgArray.count; i ++) {
                NSString *msgStr = [msgArray objectAtIndex:i];
                HtmlMedia *media = [HtmlMedia htmlMediaWithString:msgStr showType:MediaShowTypeAll];
                msgStr = media.contentDisplay;
                if (i + 1 < msgArray.count) {
                    [tipStr appendString:[NSString stringWithFormat:@"%@\n",msgStr]];
                } else {
                    [tipStr appendString:msgStr];
                }
            }
        } else {
            if (error.userInfo[NSUnderlyingErrorKey]) {
                tipStr = [self tipFromError:error.userInfo[NSUnderlyingErrorKey]].mutableCopy;
            } else if (error.userInfo[NSLocalizedDescriptionKey]) {
                tipStr = error.userInfo[NSLocalizedDescriptionKey];
            } else {
                if (error.code == 3840) {//Json 解析失败
                    [tipStr appendFormat:@"服务器返回数据格式有误"];
                }else{
                    [tipStr appendFormat:@"错误代码 %ld", (long)error.code];
                }
            }
        }
        return tipStr;
    }
    return nil;
}

#pragma mark - Show StatusBar
+ (void)showStatusBarQueryStr:(NSString *)tipStr {
    [JDStatusBarNotification showWithStatus:tipStr styleName:JDStatusBarStyleSuccess];
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleWhite];
}

+ (void)showStatusBarSuccessStr:(NSString *)tipStr {
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    } else {
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:tipStr dismissAfter:1.0 styleName:JDStatusBarStyleSuccess];
    }
}

+ (void)showStatusBarErrorStr:(NSString *)errorStr {
    if ([JDStatusBarNotification isVisible]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
            [JDStatusBarNotification showWithStatus:errorStr dismissAfter:1.5 styleName:JDStatusBarStyleError];
        });
    }else{
        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleWhite];
        [JDStatusBarNotification showWithStatus:errorStr dismissAfter:1.5 styleName:JDStatusBarStyleError];
    }
}

+ (void)showStatusBarError:(NSError *)error {
    NSString *errorStr = [NSObject tipFromError:error];
    [NSObject showStatusBarErrorStr:errorStr];
}

#pragma mark - BaseURL
+ (NSString *)baseURLStr{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kBaseURLStr] ?: kBaseURLStr;
}

+ (void)changeBaseURLStrTo:(NSString *)baseURLStr {
    if (baseURLStr.length <= 0) {
        baseURLStr = kBaseURLStr;
    } else if ([baseURLStr hasSuffix:@"/"]) {
        baseURLStr = [baseURLStr stringByAppendingString:@"/"];
    }
    
    //保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:baseURLStr forKey:kBaseURLStr];
    [defaults synchronize];
    
    [CodingNetAPIClient changeJsonClient];
    
    //更改导航栏
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[self baseURLStrIsProduction]? kColorNavBG: kColorActionYellow] forBarMetrics:UIBarMetricsDefault];
    
}

+ (BOOL)baseURLStrIsProduction{
    return [[self baseURLStr] isEqualToString:kBaseURLStr];
}

#pragma mark - 网络请求
+ (BOOL)saveResponseData:(NSDictionary *)data toPath:(NSString *)requestPath {
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return NO;
    } else {
        requestPath = [NSString stringWithFormat:@"%@_%@",loginUser.global_key,requestPath];
    }
    if ([self createDirInCache:kPath_ResponseCache]) {   //创建缓存文件夹成功
        //缓存数据文件绝对路径
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist",[self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
        return [data writeToFile:abslutePath atomically:YES];
    } else {
        return NO;
    }
}

+ (id)loadResponseWithPath:(NSString *)requestPath {
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return nil;
    } else {
        requestPath = [NSString stringWithFormat:@"%@_%@", loginUser.global_key, requestPath];
    }
    NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
    return [NSMutableDictionary dictionaryWithContentsOfFile:abslutePath];
}

+ (BOOL)deleteResponseCacheForPath:(NSString *)requestPath {
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return NO;
    } else {
        requestPath = [NSString stringWithFormat:@"%@_%@", loginUser.global_key, requestPath];
    }
    NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:abslutePath]) {
        return [fileManager removeItemAtPath:abslutePath error:nil];
    } else {
        return NO;
    }
}

//删除所有缓存数据
+ (BOOL)deleteResponseCache {
    return [self deleteCacheWithPath:kPath_ResponseCache];
}

//获取缓存数据大小
+ (NSUInteger)getResponseCacheSize {
    NSString *dirPath = [self pathInCacheDirectory:kPath_ResponseCache];
    NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

#pragma mark - File
+ (BOOL)createDirInCache:(NSString *)dirName {
    //文件夹路径
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判读文件夹是否存在,不存在才创建
    BOOL isDir = NO;
    BOOL isCreated = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES)) {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

+ (BOOL) deleteCacheWithPath:(NSString *)cachePath {
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDeleted = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (existed == YES && isDir == YES) {
        isDeleted = [fileManager removeItemAtPath:dirPath error:nil];
    }
    return isDeleted;
}

+ (NSString *)pathInCacheDirectory:(NSString *)fileName {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    return [cachePath stringByAppendingPathComponent:fileName];
}

#pragma mark - NetError
- (id)handleResponse:(id)responseJSON {
    return [self handleResponse:responseJSON autoShowError:YES];
}


- (id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError {
    NSError *error = nil;
    //code为非0值时,表示有错
    NSInteger errorCode = [(NSNumber *)[responseJSON valueForKeyPath:@"code"] integerValue];
    
    if (errorCode != 0) {
        
        //Domin:错误域   code:错误码  userInfo:错误信息
        error = [NSError errorWithDomain:[NSObject baseURLStr] code:errorCode userInfo:responseJSON];
        //用户未登录
        if (errorCode == 1000 || errorCode == 3207) {
            if ([Login isLogin]) {
                [Login doLogout];       //抹除已登录状态
                //更新 UI 要延迟 >1.0 秒，否则屏幕可能会不响应触摸事件。。暂不知为何
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [(AppDelegate *)[UIApplication sharedApplication].delegate setupLoginViewController];
                    [UIAlertController showAlertViewWithTitle:[NSObject tipFromError:error]];
                });
            }
        } else {
            //验证码弹窗
            NSMutableDictionary *params = nil;
            if (errorCode == 907) {  //operation_need_captcha 比如：每日新增关注用户超过 20 个
                params = @{@"type": @3}.mutableCopy;
            } else if (errorCode == 1018) {   //user_not_get_request_too_many
                params = @{@"type": @1}.mutableCopy;
            }
            if (params) {
                [NSObject showCaptchaViewParams:params];
            }
            
            //错误提示
            if (autoShowError) {
                [NSObject showError:error];
            }
        }
    }
    return error;
}

#pragma mark - Show CaptchaView
+ (void)showCaptchaViewParams:(NSMutableDictionary *)params {
    //Data
    if (!params) {
        params = @{}.mutableCopy;
    }
    if (!params[@"type"]) {
        params[@"type"] = @1;
    }
    
    //Path
    NSString *path = @"api/request_valid";
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha?type=%@", [NSObject baseURLStr], params[@"type"]]];
    
    //UI
    SDCAlertController *alertV = [SDCAlertController alertControllerWithTitle:@"提示" message:@"请输入验证码" preferredStyle:SDCAlertControllerStyleAlert];
    UITextField *textF = [[UITextField alloc] init];
    textF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    textF.backgroundColor = [UIColor whiteColor];
    [textF doBorderWidth:0.5 color:nil cornerRadius:2.0];
    
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.backgroundColor = [UIColor lightGrayColor];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.clipsToBounds = YES;
    imageV.userInteractionEnabled = YES;
    [imageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
    
    [alertV.contentView addSubview:textF];
    [alertV.contentView addSubview:imageV];
    [textF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertV.contentView).offset(15);
        make.height.mas_equalTo(25);
        make.bottom.equalTo(alertV.contentView).offset(-10);
    }];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(alertV.contentView).offset(-15);
        make.left.equalTo(textF.mas_right).offset(10);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(60);
        make.centerY.equalTo(textF);
    }];
    
    //Action
    __weak typeof(imageV) weakImageV = imageV;
    [imageV bk_whenTapped:^{
        [weakImageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
    }];
    __weak typeof(alertV) weakAlertV = alertV;
    [alertV addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleCancel handler:nil]];
    [alertV addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:nil]];
    alertV.shouldDismissBlock = ^BOOL(SDCAlertAction *action) {
        BOOL shouldDismiss = [action.title isEqualToString:@"取消"];
        if (!shouldDismiss) {
            params[@"j_captcha"] = textF.text;
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
                if (data) {
                    [weakAlertV dismissWithCompletion:^{
                        [NSObject showHudTipStr:@"验证码正确"];
                    }];
                } else {
                    [weakImageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
                }
            }];
         }
        return shouldDismiss;
    };
    //present
    [alertV presentWithCompletion:^{
        [textF becomeFirstResponder];
    }];
}


@end
