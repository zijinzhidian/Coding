//
//  OTPTableViewCell.m
//  Coding
//
//  Created by apple on 2018/4/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "OTPTableViewCell.h"
#import "OTPAuthClock.h"
#import "TOTPGenerator.h"

@interface OTPTableViewCell ()
@property(nonatomic,strong)UILabel *issuerLabel, *passwordLabel, *nameLabel;
- (void)updateUI;               //更新UI
- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification;     //生成新的OTP通知
@end

@implementation OTPTableViewCell

+ (CGFloat)cellHeight {
    return 120;
}

- (void)setAuthURL:(OTPAuthURL *)authURL {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //移除上一次的通知
    [nc removeObserver:self name:OTPAuthURLDidGenerateNewOTPNotification object:_authURL];
    _authURL = authURL;
    [nc addObserver:self selector:@selector(otpAuthURLDidGenerateNewOTP:) name:OTPAuthURLDidGenerateNewOTPNotification object:_authURL];
    
    [self updateUI];
}

- (void)updateUI{
    if (!_issuerLabel) {
        _issuerLabel = [UILabel new];
        _issuerLabel.font = [UIFont systemFontOfSize:16];
        _issuerLabel.textColor = kColor666;
        [self.contentView addSubview:_issuerLabel];
        [_issuerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
    }
    if (!_passwordLabel) {
        _passwordLabel = [UILabel new];
        _passwordLabel.font = [UIFont systemFontOfSize:50];
        _passwordLabel.textColor = kColorBrandBlue;
        [self.contentView addSubview:_passwordLabel];
        [_passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(50);
        }];
    }
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = kColor999;
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
    }
    _issuerLabel.text = _authURL.issuer;
    _passwordLabel.text = _authURL.otpCode.length < 6? _authURL.otpCode: [_authURL.otpCode stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@" "];
    _nameLabel.text = _authURL.name;
}

- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification {
    [self updateUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@interface TOTPTableViewCell ()
@property(nonatomic,strong)OTPAuthClock *clockView;
@property(nonatomic,strong)UILabel *back_passwordLabel;
@property(nonatomic,assign)BOOL isDuringWarning;
@end

@implementation TOTPTableViewCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //程序将要进入前台的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentView.layer removeAllAnimations];
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Notification Actions
- (void)applicationWillEnterForeground {
    //判断是否生成了新的OTP密码，若生产了新的则更新UI
    NSString *curCode = self.authURL.otpCode;
    NSString *displayingCode = self.passwordLabel.text;
    if (![curCode isEqualToString:displayingCode]) {
        [self otpAuthURLDidGenerateNewOTP:nil];
    }
}

- (void)otpAuthURLWillGenerateNewOTP:(NSNotification *)notification {
    [self warningAnimation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.clockView invalidate];
}

#pragma mark - Actions
//重写authURL的set方法
- (void)setAuthURL:(OTPAuthURL *)authURL {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //移除上一次通知
    [nc removeObserver:self name:OTPAuthURLWillGenerateNewOTPWarningNotification object:self.authURL];
    self.authURL = authURL;
    [nc addObserver:self selector:@selector(otpAuthURLWillGenerateNewOTP:) name:OTPAuthURLWillGenerateNewOTPWarningNotification object:self.authURL];
    
    [self updateUI];
}

//重写updataUI方法
- (void)updateUI {
    [super updateUI];
    
    if (!_back_passwordLabel) {
        _back_passwordLabel = [[UILabel alloc] init];
        _back_passwordLabel.font = self.passwordLabel.font;
        _back_passwordLabel.textColor = [UIColor colorWithHexString:@"0xE15957"];
        [self.contentView addSubview:_back_passwordLabel];
        [_back_passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.passwordLabel);
        }];
    }
    if (!_clockView) {
        CGFloat clockWidth = 25.f;
        _clockView = [[OTPAuthClock alloc] initWithFrame:CGRectMake(0, 0, clockWidth, clockWidth) period:[TOTPGenerator defaultPeriod]];
        [_clockView setCenter:CGPointMake(CGRectGetWidth(self.contentView.frame) - clockWidth, CGRectGetHeight(self.contentView.frame) - clockWidth)];
        [self.contentView addSubview:_clockView];
    }
    self.back_passwordLabel.text = self.passwordLabel.text;
    self.back_passwordLabel.alpha = 0;
    self.passwordLabel.alpha = 1;
}

- (void)warningAnimation {
    NSTimeInterval period = [TOTPGenerator defaultPeriod];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    CGFloat mod = fmod(seconds, period);
    CGFloat percent = mod / period;
    
    if (percent < 0.85) {            //(26/30)
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.passwordLabel.alpha = 0;
        self.back_passwordLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.passwordLabel.alpha = 1;
            self.back_passwordLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [self warningAnimation];
        }];
    }];
}

@end


@implementation HOTPTableViewCell
@end
