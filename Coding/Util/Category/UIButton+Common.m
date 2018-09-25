//
//  UIButton+Common.m
//  Coding
//
//  Created by apple on 2018/5/4.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIButton+Common.h"

@interface UIButton ()
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;
@end

@implementation UIButton (Common)

#pragma mark - 开始请求时,UIActivityIndicatorView 提示
- (void)startQueryAnimate {
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    [self.activityIndicator startAnimating];
    self.enabled = NO;
}

- (void)stopQueryAnimate {
    [self.activityIndicator stopAnimating];
    self.enabled = YES;
}

@end
