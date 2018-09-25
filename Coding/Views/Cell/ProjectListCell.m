//
//  ProjectListCell.m
//  Coding
//
//  Created by apple on 2018/5/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectListCell.h"

#define kProjectListCell_IconHeight 55.0
#define kProjectListCell_ContentLeft (kPaddingLeftWidth+kProjectListCell_IconHeight+20)

@interface ProjectListCell ()

@property(nonatomic,strong)UIImageView *projectIconView;    //项目图片视图
@property(nonatomic,strong)UIImageView *privateIconView;    //是否为私有项目图片视图
@property(nonatomic,strong)UILabel *projectTitleLabel;      //项目名称
@property(nonatomic,strong)UILabel *ownerTitleLabel;        //项目作者

@property(nonatomic,strong)Project *project;        //项目数据

@end

@implementation ProjectListCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.privateIconView];
        
        [self.contentView addSubview:self.projectTitleLabel];
        [self.projectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView.mas_left).offset(kProjectListCell_ContentLeft);
            make.right.lessThanOrEqualTo(self.contentView).offset(0);
        }];
        
        [self.contentView addSubview:self.ownerTitleLabel];
        [self.ownerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.equalTo(self.projectTitleLabel);
            make.top.equalTo(self.projectTitleLabel.mas_bottom).offset(5);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.projectTitleLabel);
            make.centerY.mas_equalTo(self.ownerTitleLabel.mas_centerY).offset(1);
        }];
        
    }
    return self;
}

#pragma mark - Public Actions
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator {
    _project = project;
    if (!project) {
        return;
    }
    
    //Icon
    [self.projectIconView sd_setImageWithURL:[self.project.icon urlImageWithCodePathResizeToView:self.projectIconView] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    self.privateIconView.hidden = self.project.is_public.boolValue;
    
    [self.ownerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.projectTitleLabel.mas_left).offset(self.project.is_public.boolValue ? 0 : CGRectGetWidth(self.privateIconView.frame) + 10);
    }];
    
    //Title & UserName
    self.projectTitleLabel.text = self.project.name;
    self.ownerTitleLabel.text = self.project.owner_user_name;
    
    //hasSWButtons
    [self setRightUtilityButtons:hasSWButtons ? [self rightButtons] : nil WithButtonWidth:135];
    
    //hasBadgeTip
    if (hasBadgeTip) {
        NSString *badgeTip = @"";
        if (self.project.un_read_activities_count && self.project.un_read_activities_count.integerValue > 0) {
            if (self.project.un_read_activities_count.integerValue > 99) {
                badgeTip = @"99+";
            } else {
                badgeTip = self.project.un_read_activities_count.stringValue;
            }
        }
        [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10 + kProjectListCell_IconHeight, 15)];
    } else {
        [self.contentView removeBadgeTips];
    }
    
    //hasIndicator
    self.accessoryType = hasIndicator ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

+ (CGFloat)cellHeight {
    return 75;
}

#pragma mark - Private Actions
- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray array];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:self.project.pin.boolValue ? @"0xe6e6e6" : @"0x0060FF"]
                                                title:self.project.pin.boolValue ? @"取消常用" : @"设置常用"
                                           titleColor:[UIColor colorWithHexString:self.project.pin.boolValue ? @"0x0060FF" : @"0xffffff"]];
    return rightUtilityButtons;
}

#pragma mark - Getters
- (UIImageView *)projectIconView {
    if (!_privateIconView) {
        _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kProjectListCell_IconHeight, kProjectListCell_IconHeight)];
        _projectIconView.layer.cornerRadius = 2;
        _projectIconView.layer.masksToBounds = YES;
    }
    return _privateIconView;
}

- (UIImageView *)privateIconView {
    if (!_privateIconView) {
        _projectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 10, 180, 25)];
        _projectTitleLabel.textColor = kColor222;
        _projectTitleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _privateIconView;
}

- (UILabel *)projectTitleLabel {
    if (!_projectTitleLabel) {
        _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
        _privateIconView.hidden = YES;
    }
    return _projectTitleLabel;
}


- (UILabel *)ownerTitleLabel {
    if (!_ownerTitleLabel) {
        _ownerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 40, 180, 25)];
        _ownerTitleLabel.textColor = kColor999;
        _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _ownerTitleLabel;
}

@end
