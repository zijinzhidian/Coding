//
//  EaseInputTipsView.h
//  Coding
//
//  Created by apple on 2018/4/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EaseInputTipsViewType) {
    EaseInputTipsViewTypeLogin = 0,
    EaseInputTipsViewTypeRegister
};

@interface EaseInputTipsView : UIView

@property(nonatomic,copy)NSString *valueStr;
@property(nonatomic,assign,getter=isActive)BOOL active;
@property(nonatomic,assign,readonly)EaseInputTipsViewType type;
@property(nonatomic,copy)void(^selectedStringBlock)(NSString *string);

+ (instancetype)tipsViewType:(EaseInputTipsViewType)type;
- (instancetype)initWithTipsType:(EaseInputTipsViewType)type;

@end
