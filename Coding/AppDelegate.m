//
//  AppDelegate.m
//  Coding
//
//  Created by apple on 2018/4/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "XGPush.h"
#import "RootTabViewController.h"
#import "Login.h"

@interface AppDelegate ()<XGPushDelegate>

@end

@implementation AppDelegate

#pragma mark - Public Actions
- (void)setupLoginViewController {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:loginVC]];
}

- (void)setupTabViewController {
    RootTabViewController *rootVC = [[RootTabViewController alloc] init];
    rootVC.tabBar.translucent = YES;
    self.window.rootViewController = rootVC;
}

- (void)registerPush {
    XGNotificationConfigure *configure = [XGNotificationConfigure configureNotificationWithCategories:nil types:XGUserNotificationTypeAlert|XGUserNotificationTypeBadge|XGUserNotificationTypeSound];
    
    [[XGPush defaultManager] setNotificationConfigure:configure];
    [[XGPush defaultManager] startXGWithAppID:KXGPush_Id appKey:KXGPush_Key delegate:self];
}

#pragma mark - Private Actions
- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    //设置导航栏背景颜色
    [navigationBarAppearance setBackgroundImage:[UIImage imageWithColor:[NSObject baseURLStrIsProduction] ? kColorNavBG : kColorActionYellow] forBarMetrics:UIBarMetricsDefault];
    //返回按钮的箭头颜色
    [navigationBarAppearance setTintColor:kColorLightBlue];
    //设置导航栏字体大小和颜色
    NSDictionary *textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:kNavTitleFontSize],
                                     NSForegroundColorAttributeName:kColorNavTitle
                                     };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    //设置返回按钮图片
    navigationBarAppearance.backIndicatorImage = [UIImage imageNamed:@"back_green_Nav"];
    navigationBarAppearance.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"back_green_Nav"];
    //设置UITextField的光标颜色
    [[UITextField appearance] setTintColor:kColorLightBlue];
    //设置UITextView的光标颜色
    [[UITextView appearance] setTintColor:kColorLightBlue];
    //设置搜索框背景颜色
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageWithColor:kColorTableSectionBg] forBarPosition:0 barMetrics:UIBarMetricsDefault];
}

- (void)completionStartAnimationWithOptions:(NSDictionary *)launchOptions {
    //信鸽推送
    
}

#pragma mark - Push Message
//iOS7.0~10.0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
}

//iOS10.0+
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    completionHandler();
}

#pragma mark - Life Cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([Login isLogin]) {
        [self setupTabViewController];
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    }
    [self.window makeKeyAndVisible];
    
    //设置统一样式
    [self customizeInterface];
    
    NSLog(@"~~~~~~~~%@",NSHomeDirectory());
    
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
