//
//  NSObject+Common.h
//  Coding
//
//  Created by apple on 2018/4/19.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <JDStatusBarNotification/JDStatusBarNotification.h>

@interface NSObject (Common)

#pragma mark - Show And Hide
//显示自定义文字(自动消失)
+ (void)showHudTipStr:(NSString *)tipStr;
//显示网络请求错误提示信息(自动消失)
+ (BOOL)showError:(NSError *)error;
//显示正在加载,默认文字为"正在获取数据..."
+ (MBProgressHUD *)showHUDQueryStr:(NSString *)titleStr;
//隐藏正在加载的HUD
+ (NSUInteger)hideHUDQuery;
//获取网络请求错误提示信息
+ (NSString *)tipFromError:(NSError *)error;

#pragma mark - Show StatusBar
+ (void)showStatusBarQueryStr:(NSString *)tipStr;
+ (void)showStatusBarSuccessStr:(NSString *)tipStr;
+ (void)showStatusBarErrorStr:(NSString *)errorStr;
+ (void)showStatusBarError:(NSError *)error;

#pragma mark - BaseURL
+ (NSString *)baseURLStr;
+ (BOOL)baseURLStrIsProduction;
+ (void)changeBaseURLStrTo:(NSString *)baseURLStr;

#pragma mark - 网络请求
//缓存请求回来的json数据对象
+ (BOOL)saveResponseData:(NSDictionary *)data toPath:(NSString *)requestPath;
//返回一个NSDictionary类型的json数据
+ (id)loadResponseWithPath:(NSString *)requestPath;
//删除指定路径的缓存json数据对象
+ (BOOL)deleteResponseCacheForPath:(NSString *)requestPath;
//删除所有缓存数据
+ (BOOL)deleteResponseCache;
//获取缓存数据大小
+ (NSUInteger)getResponseCacheSize;

#pragma mark - File
//创建缓存文件夹
+ (BOOL)createDirInCache:(NSString *)dirName;
//删除缓存文件夹
+ (BOOL) deleteCacheWithPath:(NSString *)cachePath;
//获取fileName的完整地址
+ (NSString *)pathInCacheDirectory:(NSString *)fileName;

#pragma mark - NetError
- (id)handleResponse:(id)responseJSON;
- (id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError;

#pragma mark - Show CaptchaView
//显示图形验证码
+ (void)showCaptchaViewParams:(NSMutableDictionary *)params;

@end
