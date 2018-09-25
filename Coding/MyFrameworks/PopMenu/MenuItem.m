//
//  MenuItem.m
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

#pragma mark - Instance Methods
- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.title = title;
        self.icomImage = [UIImage imageNamed:iconName];
        self.glowColor = glowColor;
        self.index = index;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName {
    return [self initWithTitle:title iconName:iconName glowColor:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor {
    return [self initWithTitle:title iconName:iconName glowColor:glowColor index:-1];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index {
    return [self initWithTitle:title iconName:iconName glowColor:nil index:index];
}

#pragma mark - Clsaa Methods
+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index {
    MenuItem *item = [[self alloc] initWithTitle:title iconName:iconName glowColor:glowColor index:index];
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName {
    return [self itemWithTitle:title iconName:iconName glowColor:nil index:-1];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor {
    return [self itemWithTitle:title iconName:iconName glowColor:glowColor index:-1];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index {
    return [self itemWithTitle:title iconName:iconName glowColor:nil index:index];
}

@end
