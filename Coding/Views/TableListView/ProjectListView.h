//
//  ProjectListView.h
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"

typedef void(^ProjectListViewBlock)(Project *project);

@interface ProjectListView : UIView

@property(nonatomic,copy)void(^clickButtonBlock)(EaseBlankPageType curType);
@property(nonatomic,assign)BOOL useNewStyle;

//初始化
- (instancetype)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight;

//设置项目数据
- (void)setProjects:(Projects *)projects;

//刷新UI
- (void)refreshUI;

//刷新数据
- (void)refreshToQueyData;

//为项目根控制器设置搜索和扫一扫
- (void)setSearchBlock:(void(^)(void))searchBlock andScanBlock:(void(^)(void))scanBlock;

//标签栏点击事件
- (void)tabBarItemClicked;

@end
