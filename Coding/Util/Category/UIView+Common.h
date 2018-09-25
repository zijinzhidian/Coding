//
//  UIView+Common.h
//  Coding
//
//  Created by apple on 2018/4/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBadgeView.h"
#import "EaseBlankPageView.h"
#import "EaseLoadingView.h"

@interface UIView (Common)

#pragma mark - 设置圆角
//设置圆形圆角
- (void)doCircleFrame;
//取消圆形圆角
- (void)doNotCircleFrame;
//设置圆角和边框
- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;
//设置任意圆角
- (void)addRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;

#pragma mark - 添加分割线
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown;
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color;
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace;

#pragma mark - 获取线条
+ (UIView *)lineViewWithPointYY:(CGFloat)pointY;
+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color;
+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace;

#pragma mark - 根据Tag移除视图
- (void)removeViewWithTag:(NSInteger)tag;

#pragma mark - UIScrollView ScrollsToTop
- (void)setSubScrollsToTop:(BOOL)scrollsToTop;

#pragma mark - 角标(UIBadgeView)
//添加角标视图或设置角标的值,自定义中心位置
- (void)addBadgeTip:(NSString *)badgeValue withCenterPosition:(CGPoint)center;
//添加角标视图或设置角标的值,角标位于视图的右上角
- (void)addBadgeTip:(NSString *)badgeValue;
//移除角标
- (void)removeBadgeTips;

#pragma mark - 空白页面(EaseBlankPageView)
@property(nonatomic,strong)EaseBlankPageView *blankPageView;
- (void)configBlankPage:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void(^)(id sender))block;
- (void)configBlankPage:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError offsetY:(CGFloat)offsetY reloadButtonBlock:(void(^)(id sender))block;

#pragma mark - 正在加载页面(EaseLoadingView)
@property(nonatomic,strong)EaseLoadingView *loadingView;
- (void)beginLoading;
- (void)endLoading;

@end
