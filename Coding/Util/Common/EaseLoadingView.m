//
//  EaseLoadingView.m
//  Coding
//
//  Created by apple on 2018/5/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "EaseLoadingView.h"
#import "YLGIFImage.h"
#import "YLImageView.h"

@implementation EaseLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _monkeyView = [[YLImageView alloc] init];
        _monkeyView.image = [YLGIFImage imageNamed:@"loading_monkey@2x.gif"];
        [self addSubview:_monkeyView];
        [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-30);
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];
        
    }
    return self;
}

- (void)startAnimating {
    self.hidden = NO;
    _isLoading = YES;
}

- (void)stopAnimating {
    self.hidden = YES;
    _isLoading = NO;
}

@end
