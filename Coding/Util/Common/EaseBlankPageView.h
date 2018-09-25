//
//  EaseBlankPageView.h
//  Coding
//
//  Created by apple on 2018/5/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

//空白页类型
typedef NS_ENUM(NSInteger, EaseBlankPageType) {
    EaseBlankPageTypeView = 0,
    EaseBlankPageTypeActivity,
    EaseBlankPageTypeTaskResource,
    EaseBlankPageTypeTask,
    EaseBlankPageTypeTopic,
    EaseBlankPageTypeTweet,
    EaseBlankPageTypeTweetAction,
    EaseBlankPageTypeTweetOther,
    EaseBlankPageTypeTweetProject,
    EaseBlankPageTypeProject,
    EaseBlankPageTypeProjectOther,
    EaseBlankPageTypeFileDleted,
    EaseBlankPageTypeMRForbidden,
    EaseBlankPageTypeFolderDleted,
    EaseBlankPageTypePrivateMsg,
    EaseBlankPageTypeMyWatchedTopic,
    EaseBlankPageTypeMyJoinedTopic,
    EaseBlankPageTypeOthersWatchedTopic,
    EaseBlankPageTypeOthersJoinedTopic,
    EaseBlankPageTypeFileTypeCannotSupport,
    EaseBlankPageTypeViewTips,
    EaseBlankPageTypeShopOrders,
    EaseBlankPageTypeShopUnPayOrders,
    EaseBlankPageTypeShopSendOrders,
    EaseBlankPageTypeShopUnSendOrders,
    EaseBlankPageTypeNoExchangeGoods,
    EaseBlankPageTypeProject_ALL,
    EaseBlankPageTypeProject_CREATE,
    EaseBlankPageTypeProject_JOIN,
    EaseBlankPageTypeProject_WATCHED,
    EaseBlankPageTypeProject_STARED,
    EaseBlankPageTypeProject_SEARCH,
    EaseBlankPageTypeTeam,
    EaseBlankPageTypeFile,
    EaseBlankPageTypeMessageList,
    EaseBlankPageTypeViewPurchase,
    EaseBlankPageTypeCode,
    EaseBlankPageTypeWiki,
};

@interface EaseBlankPageView : UIView

@property(nonatomic,strong)UIImageView *tipView;            //图片
@property(nonatomic,strong)UILabel *titleLabel;             //标题
@property(nonatomic,strong)UILabel *tipLabel;               //文字
@property(nonatomic,strong)UIButton *actionButton;          //方法按钮
@property(nonatomic,strong)UIButton *reloadButton;          //重新加载按钮

@property(nonatomic,assign)EaseBlankPageType curType;      //空白页面类型

@property(nonatomic,copy)void(^clickButtonBlock)(EaseBlankPageType curType);    //方法按钮点击回调
@property(nonatomic,copy)void(^reloadButtonBlock)(id sender);                   //重新加载按钮点击回调
@property(nonatomic,copy)void(^loadAndShowStatusBlock)(void);                   //空白页面将要加载并显示回调

/**
 设置空白界面

 @param blankPageType 空白节目类型
 @param hasData 是否有数据
 @param hasError 是否有错误
 @param offsetY 顶部偏移量
 @param block 重新加载按钮点击回调
 */
- (void)configWithType:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError offsetY:(CGFloat)offsetY reloadButtonBlock:(void(^)(id sender))block;

@end
