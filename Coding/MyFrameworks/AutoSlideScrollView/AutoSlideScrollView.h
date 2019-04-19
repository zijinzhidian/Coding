//
//  AutoSlideScrollView.h
//  Coding
//
//  Created by apple on 2019/3/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoSlideScrollView : UIView

@property(nonatomic, strong, readonly)UIScrollView *scrollView;
@property(nonatomic, assign, readonly)NSInteger currentPageIndex;


/**
 数据源:获取总的page个数,如果少于2个,不自动滚动
 */
@property(nonatomic, copy)NSInteger(^totalPagesCount)(void);


/**
 数据源:获取第pageIndex个位置的contentView
 */
@property(nonatomic, copy)UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);


/**
 当点击的时候,执行的block
 */
@property(nonatomic, copy)void(^tapActionBlock)(NSInteger pageIndex);


/**
 当currentPageIndex改变的时候,执行的block
 */
@property(nonatomic, copy)void(^currentPageIndexChangeBlock)(NSInteger currentPageIndex);


/**
 初始化
 
 @param frame frame
 @param animationDutation 自动滚动的间隔时长(如果<=0,不自动滚动)
 */
- (instancetype)initWithFrame:(CGRect)frame anitmationDuration:(NSTimeInterval)animationDutation;

@end

NS_ASSUME_NONNULL_END
