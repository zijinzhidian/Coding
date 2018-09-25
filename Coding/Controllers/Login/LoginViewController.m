//
//  LoginViewController.m
//  Coding
//
//  Created by apple on 2018/4/16.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "LoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"
#import "Login2FATipCell.h"
#import "EaseInputTipsView.h"
#import "AppDelegate.h"
#import "OTPListViewController.h"
#import "RegisterViewController.h"
#import "CannotLoginViewController.h"
#import "ActivateViewController.h"
#import "Close2FAViewController.h"

@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)Login *myLogin;

@property(nonatomic,strong)UIButton *buttonFor2FA, *loginBtn, *underLoginBtn, *registerBtn;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;

@property(nonatomic,strong)TPKeyboardAvoidingTableView *myTableView;
@property(nonatomic,strong)EaseInputTipsView *inputTipsView;

@property(nonatomic,assign)BOOL captchaNeeded;          //是否需要图形验证码

@property(nonatomic,assign)BOOL is2FAUI;                //是否为两步验证
@property(nonatomic,copy)NSString *otpCode;             //两步验证的码

@end

@implementation LoginViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.myLogin = [[Login alloc] init];
    self.myLogin.email = [Login preUserEmail];
    
    [self.view addSubview:self.myTableView];
    //适配iOS11.0以下
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kSafeArea_Top, 0, 0, 0));
    }];
    
    [self.view addSubview:self.buttonFor2FA];
    
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.centerX.equalTo(self.view);
        make.bottom.offset(-(25 + kSafeArea_Bottom));
    }];
    
    //刷新是否需要验证码
    [self refreshCaptchaNeeded];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_inputTipsView) {
        _inputTipsView = ({
            EaseInputTipsView *tipsView = [EaseInputTipsView tipsViewType:EaseInputTipsViewTypeLogin];
            //初始化一下数据
            tipsView.valueStr = nil;
            __weak typeof(self) weakSelf = self;
            tipsView.selectedStringBlock = ^(NSString *string) {
                [weakSelf.view endEditing:YES];
                weakSelf.myLogin.email = string;
                [weakSelf.myTableView reloadData];
            };
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tipsView setY:CGRectGetMaxY(cell.frame)];
            [_myTableView addSubview:tipsView];
            tipsView;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Button Actions
- (void)goTo2FAVC {
    if (_is2FAUI) {
        Close2FAViewController *vc = [Close2FAViewController vcWithPhone:self.myLogin.email sucessBlock:^(UIViewController *vc) {
            self.is2FAUI = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        OTPListViewController *vc = [[OTPListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (void)goRegisterVC {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        RegisterViewController *registerVC = [RegisterViewController vcWithMethodType:RegisterMethodPhone registerObj:nil];
        [self.navigationController pushViewController:registerVC animated:YES];
    }
}



- (void)sendLogin {
    
    NSString *tipMsg = self.is2FAUI ? [self loginTipFor2FA] : [self.myLogin goToLoginTipWithCaptcha:_captchaNeeded];
    if (tipMsg) {
        [UIAlertController showAlertViewWithTitle:tipMsg];
        return;
    }
    
    [self.view endEditing:YES];
    self.loginBtn.enabled = NO;
    
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = CGPointMake(self.loginBtn.bounds.size.width / 2, self.loginBtn.bounds.size.height / 2);
        [self.loginBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];

    __weak typeof(self) weakSelf = self;
    if (self.is2FAUI) {
        
        [[Coding_NetAPIManager sharedManager] request_Login_With2FA:self.otpCode andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {                     //两步验证成功,进入
                //保存登陆帐号
                [Login setPreUserEmail:self.myLogin.email];
                //跳转
                [(AppDelegate *)[UIApplication sharedApplication].delegate setupTabViewController];
            } else {                        //两步验证失败,转换为登陆界面
                NSString *status_expired = error.userInfo[@"msg"][@"user_login_status_expired"];
                if (status_expired.length > 0) {
                    [weakSelf changeUITo2FAWithGK:nil];
                }
            }
        }];
        
    } else {
        
        [[Coding_NetAPIManager sharedManager] request_Login_WithPath:[self.myLogin toPath] Params:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {             //未开启两步验证且成功,直接进入
                //保存登陆帐号
                [Login setPreUserEmail:self.myLogin.email];
                //跳转
                [(AppDelegate *)[UIApplication sharedApplication].delegate setupTabViewController];
                //判断邮箱是否激活
                [self doSomethingAfterLogin];
            } else {                //失败原因
                NSString *global_key = error.userInfo[@"msg"][@"two_factor_auth_code_not_empty"];
                if (global_key.length > 0) {            //开启了两步验证,需要跳转身份验证界面
                    [weakSelf changeUITo2FAWithGK:global_key];
                } else if (error.userInfo[@"msg"][@"user_need_activate"]) {         //用户未激活
                    [NSObject showError:error];
                    //跳转激活界面
                    ActivateViewController *vc = [[ActivateViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {                //登陆失败(密码错误、图形验证码错误、用户不存在等)
                    [NSObject showError:error];
                    [weakSelf refreshCaptchaNeeded];
                }
            }
        }];
    }
}

- (void)forgetPasswordBtnClicked{
    CannotLoginViewController *vc = [CannotLoginViewController vcWithMethodType:CannotLoginMethodPhone stepIndex:0 userStr:([self.myLogin.email isPhoneNo]? self.myLogin.email: nil)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)underLoginBtnClicked {
    
}

#pragma mark - Privite Actions
//刷新是否需要验证码
- (void)refreshCaptchaNeeded {
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/login" andBlock:^(id data, NSError *error) {
        
        NSNumber *captchNeededResult = (NSNumber *)data;
        if (captchNeededResult) {
            weakSelf.captchaNeeded = [captchNeededResult boolValue];
        }
        [weakSelf.myTableView reloadData];
        
    }];
}


- (NSString *)loginTipFor2FA {
    NSString *tipStr = nil;
    if (self.otpCode.length <= 0) {
        tipStr = @"动态验证码不能为空";
    } else if (![self.otpCode isPureInt] || self.otpCode.length != 6) {
        tipStr= @"动态验证码必须是一个6位数字";
    }
    return tipStr;
}


- (void)changeUITo2FAWithGK:(NSString *)global_key {
    self.otpCode = [OTPListViewController otpCodeWithGK:global_key];
    self.is2FAUI = global_key.length > 0;
    //若存在两步验证码,则进行身份验证
    if (self.otpCode) {
        [self sendLogin];
    }
}

//登陆后检测邮箱是否激活
- (void)doSomethingAfterLogin {
    User *curUser = [Login curLoginUser];
    if (curUser.email.length > 0 && !curUser.email_validation.boolValue) {
        [UIAlertController showAlertViewWithTitle:@"激活邮箱" message:@"该邮箱尚未激活,请尽快去邮箱查收邮件并激活帐号。如果在收件箱中没有看到,请留意一下垃圾邮件箱子(T_T)" cancelButtoonTitle:@"取消" sureButtonTitle:@"重新激活邮件" sureHandler:^{
            [self sendActivateEmail];
        }];
    }
}

//发送激活邮件
- (void)sendActivateEmail {
    [[Coding_NetAPIManager sharedManager] request_SendActivateEmail:[Login curLoginUser].email block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"邮件已发送"];
        }
    }];
}

#pragma mark - TableView Header Footer
- (UIView *)customHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 110)];
    UILabel *headerLaber = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark2];
    headerLaber.text = self.is2FAUI ? @"两步验证" : @"登录";
    [headerView addSubview:headerLaber];
    [headerLaber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kPaddingLeftWidth);
        make.bottom.offset(0);
        make.height.mas_equalTo(42);
    }];
    return headerView;
}

- (UIView *)customFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    self.loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(kLoginPaddingLeftWidth, 55, kScreen_Width-kLoginPaddingLeftWidth*2, 50) target:self action:@selector(sendLogin)];
    [footerView addSubview:self.loginBtn];
    
    RAC(self, loginBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myLogin.email),
                                                             RACObserve(self, myLogin.password),
                                                             RACObserve(self, myLogin.j_captcha),
                                                             RACObserve(self, captchaNeeded),
                                                             RACObserve(self, is2FAUI),
                                                             RACObserve(self, otpCode)]
                                                    reduce:^id _Nullable(NSString *email,
                                                                         NSString *password,
                                                                         NSString *j_captcha,
                                                                         NSNumber *captchaNeeded,
                                                                         NSNumber *is2FAUI,
                                                                         NSString *otpCode){
                                                        if (is2FAUI && [is2FAUI boolValue]) {
                                                            return @(otpCode.length > 0);
                                                        } else {
                                                            if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
                                                                return @(NO);
                                                            } else {
                                                                return @((email && email.length > 0) && (password && password.length > 0));
                                                            }
                                                        }
                                                    }];
    
    self.underLoginBtn = ({
        UIButton *button = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
        button.tintColor = kColorDark2;
        [button setTitle:@"  微信登录" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"login_wechat"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(underLoginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.centerX.equalTo(footerView);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
        }];
        button;
    });
    
    self.underLoginBtn.hidden = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    
    UIButton *forgetPasswordBtn = ({
        UIButton *button = [[UIButton alloc] init];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:kColorDark4 forState:UIControlStateNormal];
        [button setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [footerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(90, 30));
            make.top.offset(15);
            make.right.offset(-kPaddingLeftWidth);
        }];
        button;
    });
     [forgetPasswordBtn addTarget:self action:@selector(forgetPasswordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    return footerView;
}

#pragma mark - UITableViewDadaSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _is2FAUI ? 2 : _captchaNeeded ? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.is2FAUI && indexPath.row == 0) {
        Login2FATipCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Login2FATipCell forIndexPath:indexPath];
        return cell;
    }
    
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.row > 1? kCellIdentifier_Input_OnlyText_Cell_Captcha: kCellIdentifier_Input_OnlyText_Cell_Text) forIndexPath:indexPath];
    cell.isBottomLineShow = YES;
    __weak typeof(self) weakSelf = self;
    if (self.is2FAUI) {
        
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 动态验证码" value:self.otpCode];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.otpCode = valueStr;
        };
        
    } else {
        
        switch (indexPath.row) {
            case 0: {
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                [cell setPlaceholder:@" 手机 / 邮箱 / 用户名" value:self.myLogin.email];
                cell.textValueChangedBlock = ^(NSString *text) {
                    weakSelf.myLogin.email = text;
                    weakSelf.inputTipsView.valueStr = text;
                    weakSelf.inputTipsView.active = YES;
                };
                cell.editDidBeginBlock = ^(NSString *text) {
                    weakSelf.inputTipsView.valueStr = text;
                    weakSelf.inputTipsView.active = YES;
                };
                cell.editDidEndBlock = ^(NSString *text) {
                    weakSelf.inputTipsView.active = NO;
                };
            }
                break;
                
            case 1: {
                [cell setPlaceholder:@" 密码" value:self.myLogin.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *text) {
                    weakSelf.myLogin.password = text;
                };
            }
                break;
            
            case 2: {
                [cell setPlaceholder:@" 验证码" value:self.myLogin.j_captcha];
                cell.textValueChangedBlock = ^(NSString *text) {
                    weakSelf.myLogin.j_captcha = text;
                };
            }
                break;
                
        }
        
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.is2FAUI && indexPath.row == 0) {
        return 40;
    }
    return 65;
}

#pragma mark - Getters And Setters
- (UIButton *)buttonFor2FA {
    if (!_buttonFor2FA) {
        
        _buttonFor2FA = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 115, kSafeArea_Top, 100, 50)];
        _buttonFor2FA.titleLabel.font = [UIFont systemFontOfSize:15];
        [_buttonFor2FA setTitleColor:kColorBrandBlue forState:UIControlStateNormal];
        [_buttonFor2FA setTitleColor:[UIColor colorWithHexString:@"0x0060FF" andAlpha:0.5] forState:UIControlStateHighlighted];
        [_buttonFor2FA setTintColor:kColorBrandBlue];
        [_buttonFor2FA setTitle:@"  两步验证" forState:UIControlStateNormal];
        [_buttonFor2FA setImage:[[UIImage imageNamed:@"twoFABtn_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
         [_buttonFor2FA addTarget:self action:@selector(goTo2FAVC) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _buttonFor2FA;
}

- (TPKeyboardAvoidingTableView *)myTableView {
    if (!_myTableView) {
        
        //iOS11由于safeAreaInset影响了adjustContentInset,会导致内容视图的偏移
        _myTableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        [_myTableView registerClass:[Login2FATipCell class] forCellReuseIdentifier:kCellIdentifier_Login2FATipCell];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        _myTableView.tableHeaderView = [self customHeaderView];
        _myTableView.tableFooterView = [self customFooterView];
    }
    return _myTableView;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        
        _registerBtn = [[UIButton alloc] init];
        _registerBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_registerBtn setTitleColor:kColorDark2 forState:UIControlStateNormal];
        [_registerBtn setTitle:@"注册新账号" forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(goRegisterVC) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _registerBtn;
}

- (void)setCaptchaNeeded:(BOOL)captchaNeeded {
    _captchaNeeded = captchaNeeded;
    if (!captchaNeeded) {
        self.myLogin.j_captcha = nil;
    }
}

- (void)setIs2FAUI:(BOOL)is2FAUI {
    _is2FAUI = is2FAUI;
    
    UILabel *headerLabel = self.myTableView.tableHeaderView.subviews.firstObject;
    headerLabel.text = self.is2FAUI ? @"两步验证" : @"登陆";
    if (!_is2FAUI) {
        self.otpCode = nil;
        [_buttonFor2FA setTitle:@"  两步验证" forState:UIControlStateNormal];
        [_buttonFor2FA setImage:[[UIImage imageNamed:@"twoFABtn_Nav"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [_buttonFor2FA setTitle:@"关闭两步验证" forState:UIControlStateNormal];
        [_buttonFor2FA setImage:nil forState:UIControlStateNormal];
    }
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:_is2FAUI ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
}

@end
