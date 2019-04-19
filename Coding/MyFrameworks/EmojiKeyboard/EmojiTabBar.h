//
//  EmojiTabBar.h
//  Coding
//
//  Created by apple on 2019/3/26.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmojiTabBar : UIView

- (instancetype)initWithFrame:(CGRect)frame selectedImages:(NSArray *)selectedIamges unSelectedImages:(NSArray *)unSelectedImages;

@property(nonatomic, copy)void(^sendButtonClickedBlock)(void);
@property(nonatomic, copy)void(^selectedIndexChangedBlock)(EmojiTabBar *tabBar);

@property(nonatomic, assign)NSInteger selectedIndex;

@end

NS_ASSUME_NONNULL_END
