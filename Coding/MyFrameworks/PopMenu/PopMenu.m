//
//  PopMenu.m
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "PopMenu.h"

#define MenuButtonHeight 135                    //按钮高度
#define MenuButtonVerticalPadding 10            //水平距离
#define MenuButtonHorizontalMargin 10           //垂直距离
#define MenuButtonAnimationTime 0.1             //动画时间
#define MenuButtonAnimationInterval (MenuButtonAnimationTime / 5)       //动画间隙

#define kMenuButtonBaseTag 100

@interface PopMenu ()
@property(nonatomic,strong)NSArray *items;      //菜单元素数组
@property(nonatomic,strong)XHRealTimeBlur *realTimeBlur;     //毛玻璃视图
@property(nonatomic,strong)MenuItem *selectedItem;          //选中的菜单元素
@property(nonatomic,assign)BOOL isShow;                     //是否正在显示

@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,assign)CGPoint endPoint;

@end

@implementation PopMenu

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = items;
        [self setup];
    }
    return self;
}

#pragma mark - Public Actions
- (void)showMenuAtView:(UIView *)containerView {
    CGPoint startPoint = CGPointMake(0, CGRectGetHeight(self.bounds));
    CGPoint endPoint = startPoint;
    [self showMenuAtView:containerView startPoint:startPoint endPoint:endPoint];
}

- (void)showMenuAtView:(UIView *)containerView startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (self.isShow) {
        return;
    }
    self.startPoint = startPoint;
    self.endPoint = endPoint;
    self.clipsToBounds = YES;
    [containerView addSubview:self];
    [self.realTimeBlur showBlurViewAtView:self];
}

- (void)dismissMenu {
    if (!self.isShow) {
        return;
    }
    [self.realTimeBlur disMiss];
}

#pragma mark - Private Actions
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.perRowItemCount = 3;
    
    __weak typeof(self) weakSelf = self;
    self.realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    self.realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    self.realTimeBlur.showDuration = 0.3;
    self.realTimeBlur.disMissDuration = 0.1;
    self.realTimeBlur.hasTapGestureEnable = YES;
    
    self.realTimeBlur.willShowBlurViewcomplted = ^{
        weakSelf.isShow = YES;
        [weakSelf showItems];
    };
    
    self.realTimeBlur.willDismissBlurViewCompleted = ^{
        if (weakSelf.selectedItem) {
            if (weakSelf.didSelectedItemCompletion) {
                weakSelf.didSelectedItemCompletion(weakSelf.selectedItem);
                weakSelf.selectedItem = nil;
            }
        } else {
            if (weakSelf.didSelectedItemCompletion) {
                weakSelf.didSelectedItemCompletion(nil);
            }
        }
        [weakSelf hidenItems];
    };
    
    self.realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
        weakSelf.isShow = NO;
        [weakSelf removeFromSuperview];
    };
    
}

- (void)showItems {
    NSArray *items = self.items;
    NSInteger perRowItemCount = self.perRowItemCount;
    
    CGFloat menuButtonWidth = (CGRectGetWidth(self.bounds) - (perRowItemCount + 1) * MenuButtonHorizontalMargin) / perRowItemCount;
    
    __weak typeof(self) weakSelf = self;
    for (int index = 0; index < items.count; index++) {
        MenuItem *menuItem = items[index];
        //如果没有自定义index,就按照正常流程,从0开始
        if (menuItem.index < 0) {
            menuItem.index = index;
        }
        MenuButton *menuButton = (MenuButton *)[self viewWithTag:kMenuButtonBaseTag + index];
        
        CGRect toRect = [self getFrameWithItemCount:items.count
                                    perRowItemCount:perRowItemCount
                                  perColumItemCount:items.count/perRowItemCount+(items.count%perRowItemCount>0?1:0)
                                          itemWidth:menuButtonWidth
                                         itemHeight:MenuButtonHeight
                                           paddingX:MenuButtonVerticalPadding
                                           paddingY:MenuButtonHorizontalMargin
                                            atIndex:index
                                             onPage:0];
        
        CGRect fromRect = toRect;
        switch (self.menuAnimationType) {
            case kPopMenuAnimationTypeSina:
                fromRect.origin.y = self.startPoint.y;
                break;
        }
        if (!menuButton) {
            menuButton = [[MenuButton alloc] initWithFrame:fromRect menuItem:menuItem];
            menuButton.tag = kMenuButtonBaseTag + index;
            menuButton.didSelectedItemCompleted = ^(MenuItem *menuItem) {
                weakSelf.selectedItem = menuItem;
                [weakSelf dismissMenu];
            };
            [self addSubview:menuButton];
        } else {
            menuButton.frame = fromRect;
        }
        
        double delayInSeconds = (items.count - index) * MenuButtonAnimationInterval;
        [self initailzerAnimationWithToPostion:toRect formPostion:fromRect atView:menuButton beginTime:delayInSeconds];
        
    }
}

- (void)hidenItems {
    NSArray *items = self.items;
    for (int index = 0; index < items.count; index ++) {
        MenuButton *menuButton = (MenuButton *)[self viewWithTag:kMenuButtonBaseTag + index];
        
        CGRect fromRect = menuButton.frame;
        
        CGRect toRect = fromRect;
        switch (self.menuAnimationType) {
            case kPopMenuAnimationTypeSina:
                toRect.origin.y = self.endPoint.y;
                break;
        }
        double delayInSeconds = index * MenuButtonAnimationInterval;
        [self initailzerAnimationWithToPostion:toRect formPostion:fromRect atView:menuButton beginTime:delayInSeconds];
    }
}

/**
 *  通过目标的参数，获取一个grid布局  网格布局
 *
 *  @param perRowItemCount   每行有多少列
 *  @param perColumItemCount 每列有多少行
 *  @param itemWidth         gridItem的宽度
 *  @param itemHeight        gridItem的高度
 *  @param paddingX          gridItem之间的X轴间隔
 *  @param paddingY          gridItem之间的Y轴间隔
 *  @param index             某个gridItem所在的index序号
 *  @param page              某个gridItem所在的页码
 *
 *  @return 返回一个已经处理好的gridItem frame
 */
- (CGRect)getFrameWithItemCount:(NSInteger)itemCount
                perRowItemCount:(NSInteger)perRowItemCount
              perColumItemCount:(NSInteger)perColumItemCount
                      itemWidth:(CGFloat)itemWidth
                     itemHeight:(NSInteger)itemHeight
                       paddingX:(CGFloat)paddingX
                       paddingY:(CGFloat)paddingY
                        atIndex:(NSInteger)index
                         onPage:(NSInteger)page {
    
    //顶部偏移距离
    CGFloat indexY = kScreen_Height * 0.12;
    
    CGFloat originX = (index % perRowItemCount) * (itemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds));
    CGFloat originY = ((index / perRowItemCount) - perColumItemCount * page) * (itemHeight + paddingY) + paddingY;
    
    return CGRectMake(originX, originY + indexY, itemWidth, itemHeight);
    
}

#pragma mark - Animation
- (void)initailzerAnimationWithToPostion:(CGRect)toRect formPostion:(CGRect)fromRect atView:(UIView *)view beginTime:(CFTimeInterval)beginTime {
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    springAnimation.removedOnCompletion = YES;
    springAnimation.beginTime = beginTime + CACurrentMediaTime();
    springAnimation.springBounciness = 6;
    springAnimation.springSpeed = 2;
    springAnimation.fromValue = [NSValue valueWithCGRect:fromRect];
    springAnimation.toValue = [NSValue valueWithCGRect:toRect];
    [view pop_addAnimation:springAnimation forKey:@"POPSpringAnimationKey"];
}

@end
