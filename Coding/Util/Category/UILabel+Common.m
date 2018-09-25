//
//  UILabel+Common.m
//  Coding
//
//  Created by apple on 2018/4/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UILabel+Common.h"

@implementation UILabel (Common)

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [self new];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
