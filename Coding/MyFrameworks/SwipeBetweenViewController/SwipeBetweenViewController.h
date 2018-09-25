//
//  SwipeBetweenViewController.h
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseNavigationController.h"

@interface SwipeBetweenViewController : BaseNavigationController

@property(nonatomic,strong)NSMutableArray *viewControllerArray;     //子控制器数组
@property(nonatomic,strong,readonly)UIPageViewController *pageController;     //分页控制器
@property(nonatomic,strong)NSArray *buttonText;                 //导航栏标题数组
@property(nonatomic,strong)UIView *navigationView;

/**
 初始化
 */
+ (instancetype)newSwipeBetweenViewControllers;

/**
 获取当前控制器
 */
- (UIViewController *)curViewController;

@end
