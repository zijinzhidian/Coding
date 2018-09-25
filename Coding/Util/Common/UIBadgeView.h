//
//  UIBadgeView.h
//  StringByMatch
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 一个红色内圈白色外圈的角标视图
 */

#import <UIKit/UIKit.h>

@interface UIBadgeView : UIView

@property(nonatomic,copy)NSString *badgeValue;

//初始化
+ (UIBadgeView *)viewWithBadgeTip:(NSString *)badgeValue;

//根据角标的值和字体大小获取文字的尺寸size(不是角标的尺寸)
+ (CGSize)badgeSizeWithStr:(NSString *)badgeValue font:(UIFont *)font;
//根据角标的值获取文字的尺寸size(不是角标的尺寸)
- (CGSize)badgeSizeWithStr:(NSString *)badgeValue;

@end
