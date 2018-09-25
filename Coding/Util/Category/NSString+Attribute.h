//
//  NSString+Attribute.h
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Attribute)

//获取除去标签后的内容,并设置标签内容的颜色
+ (NSAttributedString *)getAttributeFromText:(NSString *)text emphasizeTag:(NSString *)tag emphasizeColor:(UIColor *)color;
//根据文字设置颜色富文本
+ (NSAttributedString *)getAttributeFromText:(NSString *)text emphasize:(NSString *)emphasize emphasizeColor:(UIColor *)color;
//获取移除标签后的字符串
+ (NSString *)getStr:(NSString *)str removeEmphasize:(NSString *)emphasize;

@end
