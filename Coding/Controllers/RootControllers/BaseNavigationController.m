//
//  BaseNavigationController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()
@property (strong, nonatomic) UIView *navLineV;
@end

@implementation BaseNavigationController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //藏旧
    [self hideBorderInView:self.navigationBar];
    //添新
    if (!_navLineV) {
        _navLineV = [[UIView alloc]initWithFrame:CGRectMake(0, 44, kScreen_Width, kLine_MinHeight)];
        _navLineV.backgroundColor = kColorD8DDE4;
        [self.navigationBar addSubview:_navLineV];
    }
}

#pragma mark - Public Actions
- (void)hideNavBottomLine {
    [self hideBorderInView:self.navigationBar];
    if (_navLineV) {
        _navLineV.hidden = YES;
    }
}

- (void)showNavBottomLine {
    _navLineV.hidden = NO;
}

#pragma mark - Private Actions
- (void)hideBorderInView:(UIView *)view{
    if ([view isKindOfClass:[UIImageView class]]
        && view.frame.size.height <= 1) {
        view.hidden = YES;
    }
    for (UIView *subView in view.subviews) {
        [self hideBorderInView:subView];
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (![self.visibleViewController isKindOfClass:[UIAlertController class]]) {
        return [self.visibleViewController supportedInterfaceOrientations];
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
