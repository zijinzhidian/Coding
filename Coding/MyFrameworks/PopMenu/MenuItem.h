//
//  MenuItem.h
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

/**
 标题
 */
@property(nonatomic,copy)NSString *title;


/**
 配图
 */
@property(nonatomic,strong)UIImage *icomImage;

/**
 按钮索引
 */
@property(nonatomic,assign)NSInteger index;


/**
 图片背景渲染颜色
 */
@property(nonatomic,strong)UIColor *glowColor;

#pragma mark - Init
- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index;

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);


+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

@end
