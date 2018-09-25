//
//  EaseGitButton.h
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

//按钮类型
typedef NS_ENUM(NSInteger, EaseGitButtonType) {
    EaseGitButtonTypeStar = 0,     //收藏
    EaseGitButtonTypeWatch,        //关注
    EaseGitButtonTypeFork          //Fork
};

//按钮位置
typedef NS_ENUM(NSInteger, EaseGitButtonPosition) {
    EaseGitButtonPositionLeft = 0,      //左边按钮
    EaseGitButtonPositionRight          //右边按钮
};

@interface EaseGitButton : UIButton
@property(nonatomic,copy)NSString *normalTitle, *checkedTitle, *normalIcon, *checkedIcon;
@property(nonatomic,strong)UIColor *normalBGColor, *checkedBGColor, *normalBorderColor, *checkedBorderColor;;
@property(nonatomic,assign)NSInteger userNum;
@property(nonatomic,assign)BOOL checked;
@property(nonatomic,assign)EaseGitButtonType type;
@property(nonatomic,copy)void(^buttonClickedBlock)(EaseGitButton *button, EaseGitButtonPosition position);

- (instancetype)initWithFrame:(CGRect)frame
                  normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
                   normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
                normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
            normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
                      userNum:(NSInteger)userNum checked:(BOOL)checked;

+ (instancetype)gitButtonWithFrame:(CGRect)frame
                       normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
                        normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
                     normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
                 normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
                           userNum:(NSInteger)userNum checked:(BOOL)checked;

+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame type:(EaseGitButtonType)type;

@end
