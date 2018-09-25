//
//  NSString+Attribute.m
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "NSString+Attribute.h"

@implementation NSString (Attribute)

#pragma mark - Public Actions
//设置标签内容的颜色
+ (NSAttributedString *)getAttributeFromText:(NSString *)text emphasizeTag:(NSString *)tag emphasizeColor:(UIColor *)color {
    if (text.length == 0) {
        return nil;
    }
    //例如:@"123<em>456</em>789"
    NSMutableString *mutableText = [[NSMutableString alloc] initWithString:text];
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] init];
    
    //开始标签
    NSString *sepratorStart = [NSString stringWithFormat:@"<%@>",tag];
    //结束标签
    NSString *sepratorEnd = [NSString stringWithFormat:@"</%@>",tag];
    //循环查找出开始标签和结束标签之间的内容
    while ([mutableText rangeOfString:sepratorStart].location != NSNotFound) {
        //开始标签的位置 (3,4)
        NSRange startRange = [mutableText rangeOfString:sepratorStart];
        //resultStr拼接后 (@"123")
        [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[mutableText substringWithRange:NSMakeRange(0, startRange.location)]]];
        //mutableText删除后 (456</em>789)
        [mutableText deleteCharactersInRange:NSMakeRange(0, startRange.location + startRange.length)];
    
        if ([mutableText rangeOfString:sepratorEnd].location != NSNotFound) {
            //结束标签的位置 (3,5)
            NSRange endRange = [mutableText rangeOfString:sepratorEnd];
            //标签之间内容的位置(3,3)
            NSRange storeRange = NSMakeRange(resultStr.length, endRange.location);
            //resultStr拼接后 (@"123456")
            [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[mutableText substringWithRange:NSMakeRange(0, endRange.location)]]];
            //mutableText删除后(@"789")
            [mutableText deleteCharactersInRange:NSMakeRange(0, endRange.location + endRange.length)];
            //设置标签内容的富文本(@"456")
            resultStr = [NSString getAttributeFromText:resultStr range:storeRange emphasizeColor:color];
        }
    }
    
    //尾部
    if (mutableText.length > 0) {
        //resultStr拼接后 (@"123456789")
        [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:mutableText]];
    }
    return resultStr;
}

//根据文字设置颜色富文本
+ (NSAttributedString *)getAttributeFromText:(NSString *)text emphasize:(NSString *)emphasize emphasizeColor:(UIColor *)color {
    NSMutableAttributedString *titleColorStr = [[NSMutableAttributedString alloc] initWithString:text];
    [titleColorStr addAttribute:NSForegroundColorAttributeName value:color range:[text rangeOfString:emphasize]];
    return titleColorStr;
}

//获取移除标签后的字符串
+ (NSString *)getStr:(NSString *)str removeEmphasize:(NSString *)emphasize {
    NSString *sepratorStart = [NSString stringWithFormat:@"<%@>",emphasize];
    NSString *sepratorEnd = [NSString stringWithFormat:@"</%@>",emphasize];
    NSString *resultStr = str;
    [resultStr stringByReplacingOccurrencesOfString:sepratorStart withString:@""];
    [resultStr stringByReplacingOccurrencesOfString:sepratorEnd withString:@""];
    return resultStr;
}

#pragma mark - Private Actions
//根据位置设置颜色富文本
+ (NSMutableAttributedString *)getAttributeFromText:(NSMutableAttributedString *)text range:(NSRange)range emphasizeColor:(UIColor *)color {
    [text addAttribute:NSForegroundColorAttributeName value:color range:range];
    return text;
}

@end
