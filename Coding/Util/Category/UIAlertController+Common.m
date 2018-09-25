//
//  UIAlertController+Common.m
//  Coding
//
//  Created by apple on 2018/4/26.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIAlertController+Common.h"

@implementation UIAlertController (Common)

#pragma mark - Public Actions
+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
            cancelButtoonTitle:(NSString *)cancelButtonTile
               sureButtonTitle:(NSString *)sureButtonTitle
                   sureHandler:(void (^)(void))block {
    
    UIAlertController *alertVC = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTile && cancelButtonTile.length > 0) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelButtonTile style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancel];
    }
    
    if (sureButtonTitle && sureButtonTitle.length > 0) {
        UIAlertAction *sure = [UIAlertAction actionWithTitle:sureButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block();
            }
        }];
        [alertVC addAction:sure];
    }
    
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];
    
}

+ (void)showAlertViewWithTitle:(NSString *)title
            cancelButtoonTitle:(NSString *)cancelButtonTile
               sureButtonTitle:(NSString *)sureButtonTitle
                   sureHandler:(void (^)(void))block {
    [self showAlertViewWithTitle:title message:nil cancelButtoonTitle:cancelButtonTile sureButtonTitle:sureButtonTitle sureHandler:block];
}

+ (void)showAlertViewWithTitle:(NSString *)title
               sureButtonTitle:(NSString *)sureButtonTitle {
    [self showAlertViewWithTitle:title message:nil cancelButtoonTitle:nil sureButtonTitle:sureButtonTitle sureHandler:nil];
}

+ (void)showAlertViewWithTitle:(NSString *)title; {
    [self showAlertViewWithTitle:title sureButtonTitle:@"知道了"];
}


+ (void)showSheetViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  buttonTitles:(NSArray *)buttonTitles
              destructiveTitle:(NSString *)destructiveTitle
                   cancelTitle:(NSString *)cancelTitle
               didDismissBlock:(void (^)(NSInteger index))block {
    UIAlertController *alertVC = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    //红色按钮
    if (destructiveTitle && destructiveTitle.length > 0) {
        UIAlertAction *destructive = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(0);
            }
        }];
        [alertVC addAction:destructive];
    }
    //按钮组
    if (buttonTitles && buttonTitles.count > 0) {
        for (int i = 0; i < buttonTitles.count; i++) {
            UIAlertAction *other = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSInteger index = destructiveTitle.length > 0 ? i + 1 : i;
                if (block) {
                    block(index);
                }
            }];
            [alertVC addAction:other];
        }
    }
    //取消按钮
    if (cancelTitle && cancelTitle.length > 0) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block(-1);
            }
        }];
        [alertVC addAction:cancel];
    }
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];
}

+ (void)showSheetViewWithTitle:(NSString *)title
                  buttonTitles:(NSArray *)buttonTitles
               didDismissBlock:(void (^)(NSInteger index))block {
    [self showSheetViewWithTitle:title message:nil buttonTitles:buttonTitles destructiveTitle:nil cancelTitle:@"取消" didDismissBlock:block];
}

#pragma mark - Privite Actions
//获取当前屏幕显示的控制器
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tempWindow in windows) {
            if (tempWindow.windowLevel == UIWindowLevelNormal) {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    
    return result;
}

@end
