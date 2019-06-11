//
//  EmojiPageView.h
//  Coding
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EmojiPageViewDelegate;

@interface EmojiPageView : UIView

@property(nonatomic, weak)id<EmojiPageViewDelegate> delegate;

/**
 初始化

 @param backSpaceButtonImage 删除按钮图片
 @param buttonSize 按钮尺寸
 @param rows 行数
 @param columns 列数
 */
- (instancetype)initWithFrame:(CGRect)frame
backSpaceButtonImage:(UIImage *)backSpaceButtonImage
         buttonSize:(CGSize)buttonSize
               rows:(NSUInteger)rows
            columns:(NSUInteger)columns;


- (void)setButtonTexts:(NSMutableArray *)buttonTexts forCategory:(NSString *)category;

@end

NS_ASSUME_NONNULL_END


@protocol EmojiPageViewDelegate <NSObject>

- (void)emojiPageView:(EmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji;

- (void)emojiPageViewDidPressBackSpace:(EmojiPageView *)emojiPageView;

@end
