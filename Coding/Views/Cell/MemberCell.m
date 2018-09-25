//
//  MemberCell.m
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "MemberCell.h"

@interface MemberCell ()
//成员头像、成员权限图像
@property(nonatomic,strong)UIImageView *memberIconView, *typeIconView;
//成员名称、成员备注名称
@property(nonatomic,strong)UILabel *memberNameLabel, *memberAliasLabel;
@end

@implementation MemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.memberIconView];
        
        [self.contentView addSubview:self.memberNameLabel];

        [self.contentView addSubview:self.memberAliasLabel];
        [self.memberAliasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.memberNameLabel);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(self.contentView).offset(10);
        }];
        
        [self.contentView addSubview:self.typeIconView];
        [self.typeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.memberNameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.memberNameLabel);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
//        [self.contentView addSubview:self.rightBtn];
//        [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
//            make.size.mas_equalTo(CGSizeMake(80, 32));
//            make.centerY.equalTo(self.contentView);
//        }];
    }
    return self;
}

#pragma mark - Button Methods
- (void)rightBtnClick:(UIButton *)sender {
    if (self.rightBtnClickBlock) {
        self.rightBtnClickBlock(sender);
    }
}

#pragma mark - Public Methonds
+ (CGFloat)cellHeight {
    return 60;
}

#pragma mark - Getters And Setters
- (UIImageView *)memberIconView {
    if (!_memberIconView) {
        _memberIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MemberCell cellHeight] - 40)/2, 40, 40)];
        [_memberIconView doCircleFrame];
    }
    return _memberIconView;
}

- (UIImageView *)typeIconView {
    if (!_typeIconView) {
        _typeIconView = [[UIImageView alloc] init];
    }
    return _typeIconView;
}

- (UILabel *)memberNameLabel {
    if (!_memberNameLabel) {
        _memberNameLabel = [[UILabel alloc] init];
        _memberNameLabel.font = [UIFont systemFontOfSize:17];
        _memberNameLabel.textColor = kColor222;
    }
    return _memberNameLabel;
}

- (UILabel *)memberAliasLabel {
    if (!_memberAliasLabel) {
        _memberAliasLabel = [[UILabel alloc] init];
        _memberAliasLabel.font = [UIFont systemFontOfSize:12];
        _memberAliasLabel.textColor = kColor666;
    }
    return _memberAliasLabel;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (void)setCurMember:(ProjectMember *)curMember {
    _curMember = curMember;
    if (!_curMember) {
        return;
    }
    //头像
    [self.memberIconView sd_setImageWithURL:[self.curMember.user.avatar urlImageWithCodePathResizeToView:self.memberIconView] placeholderImage:kPlaceholderMonkeyRoundView(self.memberIconView)];
    //名称
    self.memberNameLabel.text = self.curMember.user.name;
    //备注
    if (self.curMember.alias.length > 0) {
        self.memberAliasLabel.text = self.curMember.alias;
        self.memberAliasLabel.hidden = NO;
    } else {
        self.memberAliasLabel.hidden = YES;
    }
    //成员权限类型
    switch (self.curMember.type.integerValue) {
        case 100:           //项目拥有者
        case 90:            //项目管理员
        case 75: {          //受限成员
            [self.typeIconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"member_type_%ld", (long)self.curMember.type.integerValue]]];
            self.typeIconView.hidden = NO;
        }
            break;
        case 80:            //普通成员
        default: {
            self.typeIconView.hidden = YES;
        }
            break;
    }
    
    [self.memberNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.memberIconView.mas_right).offset(10);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.contentView).offset(self.curMember.alias.length > 0 ? -10 : 0 );
        make.right.lessThanOrEqualTo(self.contentView).offset(-15);
    }];
}

@end
