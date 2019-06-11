//
//  EmojiKeyboardView.h
//  Coding
//
//  Created by apple on 2019/3/25.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EmojiKeyboardViewCategoryImage) {
    EmojiKeyboardViewCategoryImageEmoji,
    EmojiKeyboardViewCategoryImageEmoji_Code,
    EmojiKeyboardViewCategoryImageMonkey,
    EmojiKeyboardViewCategoryImageMonkey_Gif,
};

NS_ASSUME_NONNULL_BEGIN

@protocol EmojiKeyboardDelegate;
@protocol EmojiKeyboardDataSource;

@interface EmojiKeyboardView : UIView

@property(nonatomic, weak)id<EmojiKeyboardDelegate> delegate;
@property(nonatomic, weak)id<EmojiKeyboardDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<EmojiKeyboardDataSource>) dataSource
               showBigEmotion:(BOOL)showBigEmotion;

- (void)setDoneButtonTitle:(NSString *)doneStr;

@end

NS_ASSUME_NONNULL_END


@protocol EmojiKeyboardDelegate <NSObject>

- (void)emojiKeyboardView:(EmojiKeyboardView *)emojiKeyboardView didUseEmoji:(NSString *)emoji;

- (void)emojiKeyboardViewDidPressBackSpace:(EmojiKeyboardView *)emojiKeyboardView;

- (void)emojiKeyboardViewDidPressSendButton:(EmojiKeyboardView *)emojiKeyboardView;

@end


@protocol EmojiKeyboardDataSource <NSObject>

@required

//tabBar按钮选中图片
- (UIImage *)emojiKeyboardView:(EmojiKeyboardView *)emogiKeyboardView
      imageForSelectedCategory:(EmojiKeyboardViewCategoryImage)category;

//tabBar按钮未选中图片
- (UIImage *)emojiKeyboardView:(EmojiKeyboardView *)emogiKeyboardView
   imageForNonSelectedCategory:(EmojiKeyboardViewCategoryImage)category;

//删除按钮图片
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(EmojiKeyboardView *)emojiKeyboardView;

@optional
/**
 默认显示的表情分类
 */
- (EmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:(EmojiKeyboardView *)emojiKeyboardView;

@end
