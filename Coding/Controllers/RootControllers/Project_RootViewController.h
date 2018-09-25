//
//  Project_RootViewController.h
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"
#import <iCarousel/iCarousel.h>

@interface Project_RootViewController : BaseViewController

@property(nonatomic,strong)NSArray *segmentItems;       //导航栏文字数组

@property(nonatomic,strong)iCarousel *myCarousel;       //翻页控制器
@property(nonatomic,assign)BOOL icarouselScrollEnable;  //是否能滚动
@property(nonatomic,assign)NSInteger oldSelectedIndex;  //选中的carousel视图下标

@property(nonatomic,assign)BOOL useNewStyle;


@end
