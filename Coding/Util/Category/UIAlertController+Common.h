//
//  UIAlertController+Common.h
//  Coding
//
//  Created by apple on 2018/4/26.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Common)

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
            cancelButtoonTitle:(NSString *)cancelButtonTile
               sureButtonTitle:(NSString *)sureButtonTitle
                   sureHandler:(void (^)(void))block;

+ (void)showAlertViewWithTitle:(NSString *)title
            cancelButtoonTitle:(NSString *)cancelButtonTile
               sureButtonTitle:(NSString *)sureButtonTitle
                   sureHandler:(void (^)(void))block;

+ (void)showAlertViewWithTitle:(NSString *)title
               sureButtonTitle:(NSString *)sureButtonTitle;

+ (void)showAlertViewWithTitle:(NSString *)title;


+ (void)showSheetViewWithTitle:(NSString *)title
                       message:(NSString *)message
                  buttonTitles:(NSArray *)buttonTitles
              destructiveTitle:(NSString *)destructiveTitle
                   cancelTitle:(NSString *)cancelTitle
               didDismissBlock:(void (^)(NSInteger index))block;


+ (void)showSheetViewWithTitle:(NSString *)title
                  buttonTitles:(NSArray *)buttonTitles
               didDismissBlock:(void (^)(NSInteger index))block;

@end
