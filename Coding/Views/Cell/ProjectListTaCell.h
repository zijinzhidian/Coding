//
//  ProjectListTaCell.h
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

#define kCellIdentifier_ProjectListTaCell @"ProjectListTaCell"

@interface ProjectListTaCell : UITableViewCell
@property(nonatomic,strong)Project *project;
+ (CGFloat)cellHeight;
@end
