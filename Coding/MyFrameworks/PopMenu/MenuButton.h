//
//  MenuButton.h
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
#import <pop/POP.h>

typedef void(^DidSelectedItemCompletedBlock)(MenuItem *menuItem);

@interface MenuButton : UIView

/**
 点击操作
 */
@property(nonatomic,copy)DidSelectedItemCompletedBlock didSelectedItemCompleted;


/**
 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame menuItem:(MenuItem *)menuItem;

@end
