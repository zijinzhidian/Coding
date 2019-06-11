//
//  UIMessageInputView.h
//  Coding
//
//  Created by apple on 2019/3/20.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiKeyboardView.h"

typedef NS_ENUM(NSInteger, UIMessageInputViewContentType) {
    UIMessageInputViewContentTypeTweet = 0,                 //冒泡评论
    UIMessageInputViewContentTypePriMsg,                    //私有消息
    UIMessageInputViewContentTypeTopic,                     //发表看法
    UIMessageInputViewContentTypeTask                       //任务评论
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,              //系统键盘
    UIMessageInputViewStateEmotion,             //表情键盘
    UIMessageInputViewStateAdd,                 //添加键盘
    UIMessageInputViewStateVoice                //说话键盘
};

NS_ASSUME_NONNULL_BEGIN

@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView : UIView

@property(nonatomic, weak)id<UIMessageInputViewDelegate> delegate;          //代理

@property(nonatomic, copy)NSString *placeHolder;            //输入框提示问题
@property(nonatomic, assign, readonly)UIMessageInputViewContentType contentType;        //内容类型
@property(nonatomic, assign)BOOL isAlwaysShow;              //是否总是显示在底部

@property(nonatomic, strong)User *toUser;
@property(nonatomic, strong)NSNumber *commentOfId;
@property(nonatomic, strong)Project *curProject;

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)isCustomFirstResponder;   

@end

NS_ASSUME_NONNULL_END


@protocol UIMessageInputViewDelegate <NSObject>

@optional
//添加视图中的按钮点击回调
- (void)messageInputView:(UIMessageInputView *)inputView addIndexClick:(NSInteger)index;
//说话视图中说话完成的回调
- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration;
//点击大表情发送的回调
- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;
//点击发送消息的回调
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text;
@end
