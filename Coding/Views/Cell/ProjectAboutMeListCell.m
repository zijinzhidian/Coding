//
//  ProjectAboutMeListCell.m
//  Coding
//
//  Created by apple on 2018/5/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectAboutMeListCell.h"

#define kProjectIconSize 80             //项目图片大小
#define kSwapBtnWidth    135            //侧滑按钮宽度
#define kLeftOffset      20             //文字距项目icon的左侧距离
#define kPinIconSize     22             //常用图片大小

@interface ProjectAboutMeListCell ()
//项目数据
@property(nonatomic,strong)Project *project;
//项目图片视图、是否为私有项目图片视图、是否为常用图片
@property(nonatomic,strong)UIImageView *projectIconView, *privateIconView, *pinIconView;
//...弹出按钮
@property(nonatomic,strong)UIButton *setCommonBtn;
//项目名称
@property(nonatomic,strong)UILabel *projectTitleLabel;
//项目作者
@property(nonatomic,strong)UILabel *ownerTitleLabel;
//项目描述
@property(nonatomic,strong)UILabel *describeLabel;
@end

@implementation ProjectAboutMeListCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_projectIconView) {
            _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, kProjectIconSize, kProjectIconSize)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }
        if (!_projectTitleLabel) {
            _projectTitleLabel = [[UILabel alloc] init];
            _projectTitleLabel.textColor = kColorDark3;
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [[UILabel alloc] init];
            _ownerTitleLabel.textColor = kColorDarkA;
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
        }
        if (!_describeLabel) {
            _describeLabel = [[UILabel alloc] init];
            _describeLabel.textColor = kColorDark7;
            _describeLabel.font = [UIFont systemFontOfSize:14];
            _describeLabel.numberOfLines=1;
            [self.contentView addSubview:_describeLabel];
        }
        if (!_privateIconView) {
            _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
            _privateIconView.hidden = YES;
            [self.contentView addSubview:_privateIconView];
        }
        if (!_pinIconView) {
            _pinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_cell_setNormal"]];
            _pinIconView.hidden = YES;
            [self.contentView addSubview:_pinIconView];
            [_pinIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kPinIconSize, kPinIconSize));
                make.top.equalTo(self.projectIconView).offset(6);
                make.right.equalTo(self.projectIconView).offset(-5);
            }];
        }
        if (!_setCommonBtn) {
            _setCommonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _setCommonBtn.hidden = YES;
            [_setCommonBtn setImage:[UIImage imageNamed:@"btn_setFrequent"] forState:UIControlStateNormal];
            [self.contentView addSubview:_setCommonBtn];
            [_setCommonBtn addTarget:self action:@selector(showSliderAction) forControlEvents:UIControlEventTouchUpInside];
            [_setCommonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(35, 20));
                make.right.equalTo(self).offset(-15+11);
                make.bottom.equalTo(self.projectIconView).offset(5);
            }];
        }

    }
    return self;
}

#pragma mark - Public Actions
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator {
    _project = project;
    if (!_project) {
        return;
    }
    //Icon
    [_projectIconView sd_setImageWithURL:[_project.icon urlImageWithCodePathResizeToView:_projectIconView] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
     _privateIconView.hidden =(_project.is_public!=nil)? _project.is_public.boolValue:([_project.type intValue]==2)?FALSE:TRUE;
    if (_hidePrivateIcon) {
        _privateIconView.hidden=TRUE;
    }
    
    [_privateIconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_privateIconView.hidden?CGSizeZero:CGSizeMake(12, 12));
        make.centerY.equalTo(_projectTitleLabel.mas_centerY);
        make.left.equalTo(_projectIconView.mas_right).offset(kLeftOffset);
    }];
    
    [_projectTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_projectIconView.mas_top);
        make.height.equalTo(@(20));
        make.left.equalTo(_privateIconView.mas_right).offset(_privateIconView.hidden?0:8);
        make.right.lessThanOrEqualTo(self.mas_right).offset(-kPaddingLeftWidth);
    }];
    
    [_ownerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.projectTitleLabel);
        make.left.equalTo(self.privateIconView);
        make.bottom.equalTo(_projectIconView.mas_bottom);
    }];
    
    [_describeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.privateIconView);
        make.height.equalTo(@(38));
        make.width.equalTo(@(kScreen_Width-kLeftOffset-kPinIconSize-20));
        make.top.equalTo(_projectTitleLabel.mas_bottom);
    }];
    
    //Title & UserName & Description
    if (_openKeywords) {
        _projectTitleLabel.attributedText = [NSString getAttributeFromText:_project.name emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    } else {
        _projectTitleLabel.text = _project.name;
    }
    
    if (_openKeywords) {
        _describeLabel.attributedText = [NSString getAttributeFromText:_project.description_mine emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    }else{
        _describeLabel.text=_project.description_mine;
    }
    
    _ownerTitleLabel.text = _project.owner_user_name ? _project.owner_user_name : [[[[_project.project_path componentsSeparatedByString:@"/p"] firstObject] componentsSeparatedByString:@"u/"] lastObject];   //@"/u/beldon/p/spring-cloud-learn"
    
    //hasSWButtons
    [self setRightUtilityButtons:hasSWButtons? [self rightButtons]: nil
                 WithButtonWidth:kSwapBtnWidth];
    
    //hasBadgeTip
    if (hasBadgeTip) {
        NSString *badgeTip = @"";
        if (_project.un_read_activities_count && _project.un_read_activities_count.integerValue > 0) {
            if (_project.un_read_activities_count.integerValue > 99) {
                badgeTip = @"99+";
            }else{
                badgeTip = _project.un_read_activities_count.stringValue;
            }
        }
        [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kPinIconSize, 15)];
    }else{
        [self.contentView removeBadgeTips];
    }
    
    //hasIndicator
    self.accessoryType = hasIndicator? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    _pinIconView.hidden = !_project.pin.boolValue;
    _setCommonBtn.hidden = !hasSWButtons;
}

#pragma mark - Private Actions
- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray array];
    [rightUtilityButtons sw_addUtilityButtonWithColor:_project.pin.boolValue? kColorTableSectionBg: kColorBrandBlue
                                                title:_project.pin.boolValue? @"取消常用": @"设置常用"
                                           titleColor:_project.pin.boolValue? kColorBrandBlue: [UIColor whiteColor]];
    return rightUtilityButtons;
}

#pragma mark - Button Actions
- (void)showSliderAction {
    [self showRightUtilityButtonsAnimated:YES];
}

@end
