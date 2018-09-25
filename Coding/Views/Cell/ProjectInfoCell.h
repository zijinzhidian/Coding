//
//  ProjectInfoCell.h
//  Coding
//
//  Created by apple on 2018/7/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 项目详情里面的项目信息cell
 */

#import <UIKit/UIKit.h>

#define kCellIdentifier_ProjectInfoCell @"ProjectInfoCell"

@interface ProjectInfoCell : UITableViewCell
@property(nonatomic,strong)Project *curProject;
@property(nonatomic,copy)void(^projectBlock)(Project *);
+ (CGFloat)cellHeight;
@end
