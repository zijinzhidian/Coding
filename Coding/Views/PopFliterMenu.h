//
//  PopFliterMenu.h
//  Coding
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopFliterMenu : UIView

@property(nonatomic,copy)void(^clickBlock)(NSInteger selectNum);
@property(nonatomic,copy)void(^closeBlock)(void);

@property(nonatomic,assign)BOOL showStatue;
@property(nonatomic,assign)NSInteger selectNum;  //选中的数据

//初始化
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;
//将菜单显示到某个视图上
- (void)showMenuAtView:(UIView *)containerView;
//隐藏视图
- (void)dismissMenu;
//刷新数据
- (void)refreshMenuData;

@end
