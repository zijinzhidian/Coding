//
//  UIViewController+Swizzle.m
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import <RDVTabBarController/RDVTabBarController.h>
#import "ObjcRuntime.h"

@implementation UIViewController (Swizzle)

#pragma mark - Load
+ (void)load {
    Swizzle([UIViewController class], @selector(viewDidAppear:), @selector(customViewDidAppear:));
    Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(customViewWillDisappear:));
    Swizzle([UIViewController class], @selector(viewWillAppear:), @selector(customViewWillAppear:));
}

#pragma mark - Swizzle
- (void)customViewDidAppear:(BOOL)animated {
    if ([NSStringFromClass([self class]) rangeOfString:@"_RootViewController"].location != NSNotFound) {
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    }
    [self customViewDidAppear:animated];
}

- (void)customViewWillAppear:(BOOL)animated {
    if ([[self.navigationController childViewControllers] count] > 1) {
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
    [self customViewWillAppear:animated];
}

- (void)customViewWillDisappear:(BOOL)animated {
    if (!self.navigationItem.backBarButtonItem && self.navigationController.viewControllers.count > 1) {
        //设置返回按钮(backBarButtonItem的图片不能设置；如果用leftBarButtonItem属性，则iOS7自带的滑动返回功能会失效)
        self.navigationItem.backBarButtonItem = [self backButton];
    }
    [self customViewWillDisappear:animated];
}

#pragma mark - BackButton
- (UIBarButtonItem *)backButton {
    NSDictionary *textAttributes;
    if ([[UIBarButtonItem appearance] respondsToSelector:@selector(setTitleTextAttributes:forState:)]){
        textAttributes = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:kBackButtonFontSize],
                           NSForegroundColorAttributeName: kColorLightBlue,
                           };
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBackButtonFontSize]} forState:UIControlStateDisabled | UIControlStateHighlighted];
    }
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(goBack_Swizzle);
    return temporaryBarButtonItem;
}

- (void)goBack_Swizzle {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
