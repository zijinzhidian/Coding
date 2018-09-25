//
//  ProjectAboutMeListCell.h
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/**
 *  全部项目 我创建的 我参与的  cell样式     :(1)支持公开/私有 两种状态，(2)支持侧滑，(3)支持置顶标识
 */


#import "SWTableViewCell.h"
#import "Project.h"

#define kProjectAboutMeListCellHeight 110

@interface ProjectAboutMeListCell : SWTableViewCell

@property(nonatomic,assign)BOOL openKeywords;       //是否显示关键词
@property(nonatomic,assign)BOOL hidePrivateIcon;    //是否隐藏私有图片
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end
