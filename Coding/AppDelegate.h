//
//  AppDelegate.h
//  Coding
//
//  Created by apple on 2018/4/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setupLoginViewController;
- (void)setupTabViewController;
- (void)registerPush;

@end

