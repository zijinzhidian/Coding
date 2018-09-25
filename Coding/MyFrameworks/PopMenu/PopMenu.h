//
//  PopMenu.h
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"
#import "XHRealTimeBlur.h"

typedef void(^DidSelectedItemBlock)(MenuItem *selectedItem);
typedef NS_ENUM(NSInteger, PopMenuAnimationType) {
    kPopMenuAnimationTypeSina = 0,      //从下部入,下部出
};

@interface PopMenu : UIView

/**
 动画样式
 */
@property(nonatomic,assign)PopMenuAnimationType menuAnimationType;

/**
 菜单中的菜单元素
 */
@property(nonatomic,strong,readonly)NSArray *items;


/**
 每行有多少列,默认为3
 */
@property(nonatomic,assign)NSInteger perRowItemCount;

/**
 是否正在显示
 */
@property(nonatomic,assign,readonly)BOOL isShow;

/**
 点击菜单元素回调
 */
@property(nonatomic,copy)DidSelectedItemBlock didSelectedItemCompletion;

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;

#pragma mark - show
- (void)showMenuAtView:(UIView *)containerView;
- (void)showMenuAtView:(UIView *)containerView startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

#pragma mark - dismiss
- (void)dismissMenu;

@end
