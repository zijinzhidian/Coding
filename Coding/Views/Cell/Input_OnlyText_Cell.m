//
//  Input_OnlyText_Cell.m
//  Coding
//
//  Created by apple on 2018/4/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Input_OnlyText_Cell.h"
#import "UITapImageView.h"

#define kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix @"Input_OnlyText_Cell_PhoneCode"

@interface Input_OnlyText_Cell ()
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIButton *passwordBtn;
@property(nonatomic,strong)UITapImageView *captchaView;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;
@end

@implementation Input_OnlyText_Cell

#pragma mark - Initail
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(21);
            make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
            make.bottom.offset(-15);
        }];
        
        
        if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]) {
            
            [self.contentView addSubview:self.captchaView];
            [self.captchaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60, 25));
                make.right.offset(-kPaddingLeftWidth);
                make.bottom.offset(-15);
            }];
            
            [self.contentView addSubview:self.activityIndicator];
            [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.captchaView);
            }];
            
        } else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
            
            self.textField.secureTextEntry = YES;
            [self.contentView addSubview:self.passwordBtn];
            
        } else if ([reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]) {
            
            [self.contentView addSubview:self.verify_codeBtn];
            [self.verify_codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 25));
                make.right.offset(-kPaddingLeftWidth);
                make.bottom.offset(-15);
            }];
            
        } else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Phone]) {
            
            [self.contentView addSubview:self.countryCodeL];
            [self.countryCodeL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
            
            UIView *lineView = ({
                UIView *view = [[UIView alloc] init];
                view.backgroundColor = kColorCCC;
                [self.contentView addSubview:view];
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.countryCodeL.mas_right).offset(8);
                    make.centerY.equalTo(self.countryCodeL);
                    make.width.mas_equalTo(0.5);
                    make.height.mas_equalTo(15);
                }];
                view;
            });
            
            UIButton *bgBtn = ({
                UIButton *button = [[UIButton alloc] init];
                [self.contentView addSubview:button];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(self.contentView);
                    make.right.equalTo(lineView);
                }];
                button;
            });
            [bgBtn addTarget:self action:@selector(countryCodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(lineView.mas_right).offset(8);
            }];
        }
    }
    return self;
}

//当被重用的cell将要显示时调用
- (void)prepareForReuse {
    [super prepareForReuse];
    
    if (![self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
        self.textField.secureTextEntry = NO;
    }
    
    self.textField.userInteractionEnabled = YES;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    
    self.editDidBeginBlock = nil;
    self.textValueChangedBlock = nil;
    self.editDidEndBlock = nil;
    self.phoneCodeBtnClickedBlock = nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isBottomLineShow) {
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kLine_MinHeight);
            make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
            make.bottom.equalTo(self.contentView);
        }];
    }
    
    UIView *rightElement;
    if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
        rightElement = nil;
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]){
        rightElement = _captchaView;
        [self refreshCaptchaImage];
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
        rightElement = _passwordBtn;
    }else if ([self.reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]){
        rightElement = _verify_codeBtn;
    }

    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement ? (CGRectGetMinX(rightElement.frame) - kScreen_Width - 10): -kLoginPaddingLeftWidth;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    
}

#pragma mark - Privite Actions
- (void)refreshCaptchaImage {
    
    if (self.activityIndicator.isAnimating) return;
    
    __weak typeof(self) weakSelf = self;
    [self.activityIndicator startAnimating];
    [self.captchaView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha",[NSObject baseURLStr]]] placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies) completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakSelf.activityIndicator stopAnimating];
    }];
    
}

- (void)passwordBtnClicked:(UIButton *)sender {
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
    [sender setImage:[UIImage imageNamed:_textField.secureTextEntry? @"password_unlook": @"password_look"] forState:UIControlStateNormal];
}

- (void)phoneCodeButtonClicked:(PhoneCodeButton *)sender {
    if (self.phoneCodeBtnClickedBlock) {
        self.phoneCodeBtnClickedBlock(sender);
    }
}

- (void)countryCodeBtnClicked:(UIButton *)sender {
    if (self.countryCodeBtnClickedBlock) {
        self.countryCodeBtnClickedBlock();
    }
}

#pragma mark - Public Actions
- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr {
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr? phStr: @"" attributes:@{NSForegroundColorAttributeName: kColorDarkA}];
    self.textField.text = valueStr;
}

+ (NSString *)randomCellIdentifierOfPhoneCodeType {
    return [NSString stringWithFormat:@"%@_%ld", kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix, random()];
}

#pragma mark - UITextFiled Events
- (void)editDidBegin:(UITextField *)textFiled {
    self.lineView.backgroundColor = kColorBrandBlue;
    if (self.editDidBeginBlock) {
        self.editDidBeginBlock(textFiled.text);
    }
}

- (void)textValueChanged:(UITextField *)textFiled {
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textFiled.text);
    }
}

- (void)editDidEnd:(UITextField *)textFiled {
    self.lineView.backgroundColor = kColorDarkA;
    if (self.editDidEndBlock) {
        self.editDidEndBlock(textFiled.text);
    }
}

#pragma mark - Getters And Setters
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textColor = kColorDark2;
        _textField.font = [UIFont systemFontOfSize:15];
        [_textField addTarget:self action:@selector(editDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
        [_textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    }
    return _textField;
}

- (UITapImageView *)captchaView {
    if (!_captchaView) {
        
        //这里需要设置frame,否则layoutSubviews会比initWithStyle:reuseIdentifier:先调用,导致自动布局失败
        _captchaView = [[UITapImageView alloc] initWithFrame:CGRectMake(kScreen_Width - 60 - kLoginPaddingLeftWidth, (44 - 25) / 2, 60, 25)];
        _captchaView.layer.masksToBounds = YES;
        _captchaView.layer.cornerRadius = 5;
        //使用self会导致循环引用
        __weak typeof(self) weakSelf = self;
        [_captchaView addTapBlock:^(id obj) {
            [weakSelf refreshCaptchaImage];
        }];
        
    }
    return _captchaView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        
    }
    return _activityIndicator;
}

- (UIButton *)passwordBtn {
    if (!_passwordBtn) {
        
        _passwordBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 44 - kLoginPaddingLeftWidth, 0, 44, 44)];
        [_passwordBtn setImage:[UIImage imageNamed:@"password_unlook"] forState:UIControlStateNormal];
        [_passwordBtn addTarget:self action:@selector(passwordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _passwordBtn;
}

- (PhoneCodeButton *)verify_codeBtn {
    if (!_verify_codeBtn) {
        
        _verify_codeBtn = [[PhoneCodeButton alloc] initWithFrame:CGRectMake(kScreen_Width - 80 - kLoginPaddingLeftWidth, (44 - 25) / 2, 80, 25)];
        [_verify_codeBtn addTarget:self action:@selector(phoneCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _verify_codeBtn;
}

- (UILabel *)countryCodeL {
    if (!_countryCodeL) {
        
        _countryCodeL = [[UILabel alloc] init];
        _countryCodeL.font = [UIFont systemFontOfSize:15];
        _countryCodeL.textColor = kColorBrandBlue;
        
    }
    return _countryCodeL;
}

- (UIView *)lineView {
    if (!_lineView) {
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = kColorDarkA;
        
    }
    return _lineView;
}

- (void)setIsBottomLineShow:(BOOL)isBottomLineShow {
    _isBottomLineShow = isBottomLineShow;
    self.lineView.hidden = !isBottomLineShow;
}

@end
