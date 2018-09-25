//
//  CategorySearchBar.m
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CategorySearchBar.h"

@implementation CategorySearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //设置背景颜色
        [self setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xEBECEC"] withFrame:CGRectMake(0, 0, 1, 28)] forState:UIControlStateNormal];
        UITextField *searchField = self.eaTextField;
        searchField.layer.masksToBounds = YES;
        searchField.layer.cornerRadius = 4.0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UITextField *searchField = self.eaTextField;
    searchField.leftView.frame = CGRectMake(8, (CGRectGetHeight(searchField.bounds) - 13)/2, 20, 13);
    searchField.leftView.contentMode = UIViewContentModeLeft;
}

@end


@implementation MainSearchBar

- (UIButton *)scanBtn {
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setImage:[UIImage imageNamed:@"button_scan"] forState:UIControlStateNormal];
        [self addSubview:_scanBtn];
        [_scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 30));
            make.centerY.equalTo(self);
            make.right.equalTo(self);
        }];
    }
    return _scanBtn;
}

@end
