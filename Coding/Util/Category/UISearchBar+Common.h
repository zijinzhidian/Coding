//
//  UISearchBar+Common.h
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (Common)

//获取输入框
- (UITextField *)eaTextField;
//设置提示文字颜色
- (void)setPlaceholderColor:(UIColor *)color;
//设置搜索图片
- (void)setSearchIcon:(UIImage *)image;

@end
