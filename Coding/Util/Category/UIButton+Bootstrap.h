//
//  UIButton+Bootstrap.h
//  Coding
//
//  Created by apple on 2018/4/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,StrapButtonStyle) {
    StrapBootstrapStyle = 0,
    StrapDefaultStyle,
    StrapPrimaryStyle,
    StrapSuccessStyle,
    StrapInfoStyle,
    StrapWarningStyle,
    StrapDangerStyle,
};

@interface UIButton (Bootstrap)

- (void)bootstrapStyle;
- (void)defaultStyle;
- (void)primaryStyle;
- (void)successStyle;
- (void)infoStyle;
- (void)warningStyle;
- (void)dangerStyle;

- (UIImage *)buttonImageFromColor:(UIColor *)color;
+ (UIButton *)buttonWithStyle:(StrapButtonStyle)style andTitle:(NSString *)title andFrame:(CGRect)rect target:(id)target action:(SEL)selector;

@end
