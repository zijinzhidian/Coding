//
//  ProjectPublicListCell.h
//  Coding
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 项目广场
 */

#import "SWTableViewCell.h"
#import "Project.h"

#define kProjectPublicListCellHeight 114

@interface ProjectPublicListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;
@end
