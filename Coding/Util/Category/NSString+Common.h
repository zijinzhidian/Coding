//
//  NSString+Common.h
//  Coding
//
//  Created by apple on 2018/4/24.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HtmlMedia.h"
#import "NSString+Emojize.h"

@interface NSString (Common)

#pragma mark - 字符类型判断
//判断是否为整形
- (BOOL)isPureInt;
//判断是否为浮点型
- (BOOL)isPureFloat;
//判断是否为手机号
- (BOOL)isPhoneNo;
//判断是否为邮箱
- (BOOL)isEmail;
//判断是否为用户名
- (BOOL)isGK;
//判断是否为文件名
- (BOOL)isFileName;

#pragma mark - 加密
//MD5加密
- (NSString *)md5Str;
//SHA1加密
- (NSString *)sha1Str;

#pragma mark - 去除特殊字符
//获取左边特殊字符范围
- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
//获取右边特殊字符范围
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;
//去掉左边特殊字符
- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
//去掉右边特殊字符
- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;
//去掉前后空格
- (NSString *)trimWhitespace;

#pragma mark - 获取字符串的尺寸
//宽高
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
//高
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
//宽
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

#pragma mark - 根据图片路径获取图片网络地址
//获取制定宽度的图片url,不裁剪
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width;
//获取指定宽度的图片url,指定是否裁剪
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop;
//获取自适应视图宽度的图片url,不裁剪
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view;

@end
