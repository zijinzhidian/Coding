//
//  EasePageViewController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "EasePageViewController.h"
#import "SwipeBetweenViewController.h"

@interface EasePageViewController ()

@end

@implementation EasePageViewController

#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //调用下当前控制器的viewDidAppear方法
    if ([self.parentViewController isKindOfClass:[SwipeBetweenViewController class]]) {
        SwipeBetweenViewController *swipeVC = (SwipeBetweenViewController *)self.parentViewController;
        [[swipeVC curViewController] viewDidAppear:animated];
    }
    NSLog(@"viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //调用下当前控制器的viewWillDisappear方法
    if ([self.parentViewController isKindOfClass:[SwipeBetweenViewController class]]) {
        SwipeBetweenViewController *swipeVC = (SwipeBetweenViewController *)self.parentViewController;
        [[swipeVC curViewController] viewWillDisappear:animated];
    }
    NSLog(@"viewWillDisappear");
}

@end
