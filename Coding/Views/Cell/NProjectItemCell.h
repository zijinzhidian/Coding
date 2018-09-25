//
//  NProjectItemCell.h
//  Coding
//
//  Created by apple on 2018/7/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 项目详情里面的ItemCell
 */

#import <UIKit/UIKit.h>

#define kCellIdentifier_NProjectItemCell @"NProjectItemCell"

@interface NProjectItemCell : UITableViewCell
- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title;
- (void)setrightText:(NSString *)rightText;
- (void)setNorightText;
- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;
- (void)addTipHeadIcon:(NSString *)IconString;

+ (CGFloat)cellHeight;
@end
