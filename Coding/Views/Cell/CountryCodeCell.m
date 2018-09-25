//
//  CountryCodeCell.m
//  Coding
//
//  Created by apple on 2018/5/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CountryCodeCell.h"

@interface CountryCodeCell ()
@property(nonatomic,strong)UILabel *leftL;
@property(nonatomic,strong)UILabel *rightL;
@end

@implementation CountryCodeCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _leftL = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = kColorDark2;
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
            label;
        });
        _rightL = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithHexString:@"0x136BFB"];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
            label;
        });
    }
    return self;
}

#pragma mark - Setter
- (void)setCountryCodeDict:(NSDictionary *)countryCodeDict{
    _countryCodeDict = countryCodeDict;
    _leftL.text = _countryCodeDict[@"country"];
    _rightL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
}

@end
