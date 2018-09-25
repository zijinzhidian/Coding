//
//  ProjectListCell.h
//  Coding
//
//  Created by apple on 2018/5/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//


#import "SWTableViewCell.h"
#import "Projects.h"

#define kCellIdentifier_ProjectList @"ProjectListCell"

@interface ProjectListCell : SWTableViewCell

- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

+ (CGFloat)cellHeight;

@end
