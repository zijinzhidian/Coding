//
//  UILongPressMenuImageView.h
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILongPressMenuImageView : UIImageView

/**
 长按菜单回调的block
 */
@property(nonatomic, copy)void(^longPressMenuBlock)(NSInteger index, NSString *title);

/**
 长按标题数组
 */
@property(nonatomic, strong)NSArray *longPressTitles;

/**
 添加菜单

 @param titles 标题组
 @param block 点击回调
 */
- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block;

@end

NS_ASSUME_NONNULL_END
