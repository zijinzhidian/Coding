//
//  MemberCell.h
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "SWTableViewCell.h"
#import "ProjectMember.h"

#define kCellIdentifier_MemberCell @"MemberCell"

@interface MemberCell : SWTableViewCell

@property(nonatomic,strong)UIButton *rightBtn;
@property(nonatomic,copy)void(^rightBtnClickBlock)(id sender);

@property(nonatomic,strong)ProjectMember *curMember;

+ (CGFloat)cellHeight;

@end
