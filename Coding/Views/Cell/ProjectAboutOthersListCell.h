//
//  ProjectAboutOthersListCell.h
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/**
 *  我关注的 我收藏的   只用公开一种状态 不支持侧滑置顶
 */

#import "SWTableViewCell.h"
#import "Project.h"

#define kProjectAboutOthersListCellHeight 104

@interface ProjectAboutOthersListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;
@end
