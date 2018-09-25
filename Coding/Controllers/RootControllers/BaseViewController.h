//
//  BaseViewController.h
//  Coding
//
//  Created by apple on 2018/4/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)tabBarItemClicked;
+ (UIViewController *)presentingVC;         //获取界面展示的视图控制器
@end
