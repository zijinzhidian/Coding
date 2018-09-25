//
//  ProjectDeleteAlertControllerVisualStyle.m
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectDeleteAlertControllerVisualStyle.h"

@implementation ProjectDeleteAlertControllerVisualStyle

- (UIColor *)titleLabelColor {
    return [UIColor colorWithRGBHex:0x222222];
}

- (UIColor *)messageLabelColor {
    return [UIColor colorWithRGBHex:0xf34a4a];
}

- (CGFloat)labelSpacing {
    return 30;
}

- (CGFloat)messageLabelBottomSpacing {
    return 14;
}

- (UIFont *)titleLabelFont {
    return [UIFont boldSystemFontOfSize:17.0];
}

- (UIFont *)messageLabelFont {
    return [UIFont boldSystemFontOfSize:14.0];
}

@end
