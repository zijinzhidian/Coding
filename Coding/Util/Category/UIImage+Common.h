//
//  UIImage+Common.h
//  Coding
//
//  Created by apple on 2018/5/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Common)

#pragma mark - 颜色生成图片
+ (UIImage *)imageWithColor:(UIColor *)aColor;
+ (UIImage *)imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame;

#pragma mark - 图片压缩为NSData
- (NSData *)dataSmallerThan:(CGFloat)maxLength;
- (NSData *)dataForCodingUpload;

@end
