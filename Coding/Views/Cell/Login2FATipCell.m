//
//  Login2FATipCell.m
//  Coding
//
//  Created by apple on 2018/4/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Login2FATipCell.h"

@implementation Login2FATipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self.contentView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kLoginPaddingLeftWidth);
            make.right.offset(-kPaddingLeftWidth);
            make.top.offset(10);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        
        _tipLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark2];
        _tipLabel.minimumScaleFactor = 0.5;
        _tipLabel.adjustsFontSizeToFitWidth = YES;
        _tipLabel.text = @"您的账户开启了两步验证,请输入动态验证码登录";

    }
    return _tipLabel;
}

@end
