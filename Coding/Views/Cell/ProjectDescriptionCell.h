//
//  ProjectDescriptionCell.h
//  Coding
//
//  Created by apple on 2018/7/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
 项目详情里面的项目描述cell
 */

#import <UIKit/UIKit.h>

#define kCellIdentifier_ProjectDescriptionCell @"ProjectDescriptionCell"

@interface ProjectDescriptionCell : UITableViewCell

- (void)setDescriptionStr:(NSString *)descriptionStr;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
