//
//  EaseGitButtonsView.h
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseGitButton.h"

//按钮高度
#define EaseGitButtonsView_Height (56.0 + kSafeArea_Bottom)

@interface EaseGitButtonsView : UIView

@property(nonatomic,strong)Project *curProject;
@property(nonatomic,copy)void(^gitButtonClickedBlock)(NSInteger index, EaseGitButtonPosition position);

@end
