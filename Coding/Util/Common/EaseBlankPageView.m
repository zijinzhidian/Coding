//
//  EaseBlankPageView.m
//  Coding
//
//  Created by apple on 2018/5/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "EaseBlankPageView.h"

@implementation EaseBlankPageView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public Action
- (void)configWithType:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError offsetY:(CGFloat)offsetY reloadButtonBlock:(void(^)(id sender))block {
    _curType = blankPageType;
    _reloadButtonBlock = block;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_loadAndShowStatusBlock) {
            _loadAndShowStatusBlock();
        }
    });
    
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    
    self.alpha = 1.0;
    
    //图片
    if (!_tipView) {
        _tipView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tipView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_tipView];
    }
    //标题
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x425063"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    //文字
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor colorWithHexString:@"0x76808E"];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
    }
    //方法按钮
    if (!_actionButton) {
        _actionButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor colorWithHexString:@"0x425063"];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.layer.cornerRadius = 4.0;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self addSubview:_actionButton];
    }
    //重新加载按钮
    if (!_reloadButton) {
        _reloadButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor colorWithHexString:@"0x425063"];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.layer.cornerRadius = 4.0;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
        [self addSubview:_reloadButton];
    }
    NSString *imageName, *titleStr, *tipStr, *buttonTitle;
    if (hasError) {
        _actionButton.hidden = YES;
        imageName = @"blankpage_image_LoadFail";
        titleStr = @"呀,网络出了问题";
        buttonTitle = @"重新连接网络";
    } else {
        _reloadButton.hidden = YES;
        switch (_curType) {
            case EaseBlankPageTypeTaskResource: {
                tipStr = @"暂无关联资源";
            }
                break;
            case EaseBlankPageTypeActivity://项目动态
            {
                imageName = @"blankpage_image_Activity";
                tipStr = @"当前项目暂无相关动态";
            }
                break;
            case EaseBlankPageTypeTask://任务列表
            {
                imageName = @"blankpage_image_Task";
                tipStr = @"这里还没有任务哦";
            }
                break;
            case EaseBlankPageTypeTopic://讨论列表
            {
                imageName = @"blankpage_image_Topic";
                tipStr = @"这里还没有讨论哦";
            }
                break;
            case EaseBlankPageTypeTweet://冒泡列表（自己的）
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有发表过冒泡呢～";
            }
                break;
            case EaseBlankPageTypeTweetAction://冒泡列表（自己的）。有发冒泡的按钮
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有发表过冒泡呢～";
                buttonTitle = @"冒个泡吧";
            }
                break;
            case EaseBlankPageTypeTweetOther://冒泡列表（别人的）
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"这里还没有冒泡哦～";
            }
                break;
            case EaseBlankPageTypeTweetProject://冒泡列表（项目内的）
            {
                imageName = @"blankpage_image_Notice";
                tipStr = @"当前项目没有公告哦～";
            }
                break;
            case EaseBlankPageTypeProject://项目列表（自己的）
            {
                imageName = @"blankpage_image_Project";
                titleStr = @"欢迎来到 Coding";
                tipStr = @"协作从项目开始，赶快创建项目吧";
            }
                break;
            case EaseBlankPageTypeProjectOther://项目列表（别人的）
            {
                imageName = @"blankpage_image_Project";
                tipStr = @"这里还没有项目哦";
            }
                break;
            case EaseBlankPageTypeFileDleted://去了文件页面，发现文件已经被删除了
            {
                tipStr = @"晚了一步，此文件刚刚被人删除了～";
            }
                break;
            case EaseBlankPageTypeMRForbidden://去了MR页面，发现没有权限
            {
                tipStr = @"抱歉，请联系项目管理员进行代码权限设置";
            }
                break;
            case EaseBlankPageTypeFolderDleted://文件夹
            {
                tipStr = @"晚了一步，此文件夹刚刚被人删除了～";
            }
                break;
            case EaseBlankPageTypePrivateMsg://私信列表
            {
                imageName = @"";//就是空
                tipStr = @"";
            }
                break;
            case EaseBlankPageTypeMyJoinedTopic://我参与的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有参与过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeMyWatchedTopic://我关注的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有关注过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeOthersJoinedTopic://ta参与的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"Ta 还没有参与过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeOthersWatchedTopic://ta关注的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"Ta 还没有关注过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeFileTypeCannotSupport:
            {
                tipStr = @"还不支持查看此类型的文件呢";
            }
                break;
            case EaseBlankPageTypeViewTips:
            {
                imageName = @"blankpage_image_Tip";
                tipStr = @"您还没有收到通知哦";
            }
                break;
            case EaseBlankPageTypeShopOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"还没有订单记录～";
            }
                break;
            case EaseBlankPageTypeShopUnPayOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有待支付的订单记录～";
            }
                break;
            case EaseBlankPageTypeShopSendOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有已发货的订单记录～";
            }
                break;
            case EaseBlankPageTypeShopUnSendOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有未发货的订单记录～";
            }
                break;
            case EaseBlankPageTypeNoExchangeGoods:{
                tipStr = @"还没有可兑换的商品呢～";
            }
                break;
            case EaseBlankPageTypeProject_ALL:
            case EaseBlankPageTypeProject_CREATE:
            case EaseBlankPageTypeProject_JOIN:{
                imageName = @"blankpage_image_Project";
                titleStr = @"欢迎来到 Coding";
                tipStr = @"协作从项目开始，赶快创建项目吧";
                buttonTitle=@"创建项目";
            }
                break;
            case EaseBlankPageTypeProject_WATCHED:{
                imageName = @"blankpage_image_Project";
                tipStr = @"您还没有关注过项目呢～";
                buttonTitle=@"去关注";
            }
                break;
            case EaseBlankPageTypeProject_STARED:{
                imageName = @"blankpage_image_Project";
                tipStr = @"您还没有收藏过项目呢～";
                buttonTitle=@"去收藏";
            }
                break;
            case EaseBlankPageTypeProject_SEARCH:{
                tipStr = @"什么都木有搜到，换个词再试试？";
            }
                break;
            case EaseBlankPageTypeTeam:{
                imageName = @"blankpage_image_Team";
                tipStr = @"您还没有参与过团队哦～";
            }
                break;
            case EaseBlankPageTypeFile:{
                imageName = @"blankpage_image_File";
                tipStr = @"这里还没有任何文件～";
            }
                break;
            case EaseBlankPageTypeMessageList:{
                imageName = @"blankpage_image_MessageList";
                tipStr = @"还没有新消息～";
            }
                break;
            case EaseBlankPageTypeViewPurchase:{
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"还没有订购记录～";
            }
                break;
            case EaseBlankPageTypeCode:
            {
                tipStr = @"当前项目还没有提交过代码呢～";
            }
                break;
            case EaseBlankPageTypeWiki:
            {
                tipStr = @"当前项目还没有创建 Wiki～";
            }
                break;
            default://其它页面（这里没有提到的页面，都属于其它）
            {
                tipStr = @"这里什么都没有～";
            }
                break;
        }
    }
    imageName = imageName ?: @"blankpage_image_Default";
    UIButton *bottomBtn = hasError ? _reloadButton : _actionButton;
    _tipView.image = [UIImage imageNamed:imageName];
    _titleLabel.text = titleStr;
    _tipLabel.text = tipStr;
    [bottomBtn setTitle:buttonTitle forState:UIControlStateNormal];
    _titleLabel.hidden = tipStr.length <= 0;
    bottomBtn.hidden = buttonTitle.length <= 0;
    
    //布局
    if (ABS(offsetY > 0)) {
        self.frame = CGRectMake(0, offsetY, self.width, self.height);
    }
    [_tipView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_bottom).multipliedBy(0.15);
        make.size.mas_equalTo(CGSizeMake(160, 160));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.top.equalTo(_tipView.mas_bottom);
    }];
    [_tipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        if (tipStr.length > 0) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        } else {
            make.top.equalTo(_tipView.mas_bottom);
        }
    }];
    [bottomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(130, 44));
        make.top.equalTo(_tipLabel.mas_bottom).offset(25);
    }];
}

#pragma mark - Button Actions
- (void)actionButtonClicked:(UIButton *)sender {
    self.hidden = YES;
    [self removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_clickButtonBlock) {
            _clickButtonBlock(_curType);
        }
    });
}

- (void)reloadButtonClicked:(UIButton *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_reloadButtonBlock) {
            _reloadButtonBlock(sender);
        }
    });
}

@end
