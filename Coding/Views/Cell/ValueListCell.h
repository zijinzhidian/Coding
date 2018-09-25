//
//  ValueListCell.h
//  Coding
//
//  Created by apple on 2018/8/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_ValueList @"ValueListCell"

@interface ValueListCell : UITableViewCell

- (void)setTitleStr:(NSString *)title imageStr:(NSString *)imageName isSelected:(BOOL)selected;

@end
