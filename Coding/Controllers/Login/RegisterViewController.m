//
//  RegisterViewController.m
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "CountryCodeListViewController.h"
#import "WebViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "EaseInputTipsView.h"
#import "UITapImageView.h"
#import "AppDelegate.h"

@interface RegisterViewController ()<UITableViewDelegate,UITableViewDataSource,TTTAttributedLabelDelegate>

@property(nonatomic,assign)RegisterMethodType methodType;
@property(nonatomic,strong)Register *myRegister;

@property(nonatomic,strong)TPKeyboardAvoidingTableView *myTableView;
@property(nonatomic,strong)UIButton *footerBtn;             //注册或下一步按钮
@property(nonatomic,strong)EaseInputTipsView *inputTipsView;

@property(nonatomic,assign)BOOL captchaNeeded;

@property(nonatomic,strong)NSDictionary *countryCodeDict;   //国家代码字典
@property(nonatomic,copy)NSString *phoneCodeCellIdentifier;

@property(nonatomic,assign)NSInteger step;

@end

@implementation RegisterViewController

#pragma mark - Init
+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType registerObj:(Register *)obj {
    RegisterViewController *registerVC = [self new];
    registerVC.methodType = methodType;
    registerVC.myRegister = obj;
    registerVC.step = 0;
    return registerVC;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setupClearBGStyle];
    
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    self.captchaNeeded = NO;
    
    //注册器
    if (!_myRegister) {
        self.myRegister = [[Register alloc] init];
    }
    //默认的国家代码
    if (!_countryCodeDict) {
        _countryCodeDict = @{@"country": @"China",
                             @"country_code": @"86",
                             @"iso_code": @"cn"};
    }
    
    [self.view addSubview:self.myTableView];
    [self.myTableView addSubview:self.inputTipsView];
    [self configBottomView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshCaptchaNeeded];
}

#pragma mark - Privite Actions
- (void)refreshCaptchaNeeded {
    if (_methodType == RegisterMethodPhone && _step <= 0) {
        self.captchaNeeded = NO;
        [self.myTableView reloadData];
    }else{
        //写死，APP 不需要
        self.captchaNeeded = NO;
        [self.myTableView reloadData];
    }
}

- (void)showCaptchaAlert:(PhoneCodeButton *)sender {
    SDCAlertController *alertV = [SDCAlertController alertControllerWithTitle:@"提示" message:@"请输入图片验证码" preferredStyle:SDCAlertControllerStyleAlert];
    //输入框
    UITextField *textF = [[UITextField alloc] init];
    textF.backgroundColor = [UIColor whiteColor];
    [textF doBorderWidth:0.5 color:nil cornerRadius:2];
    [alertV.contentView addSubview:textF];
    [textF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(alertV.contentView).offset(15);
        make.height.mas_equalTo(25);
        make.bottom.equalTo(alertV.contentView).offset(-10);
    }];
    
    //图形验证码
    UITapImageView *imageV = [[UITapImageView alloc] init];
    imageV.backgroundColor = [UIColor lightGrayColor];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    [imageV doBorderWidth:0.5 color:nil cornerRadius:2];
    [alertV.contentView addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(alertV.contentView).offset(-15);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(60);
        make.left.equalTo(textF.mas_right).offset(10);
        make.centerY.equalTo(textF);
    }];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha",[NSObject baseURLStr]]];
    __weak typeof(imageV) weakImageV = imageV;
    [imageV setImageWithUrl:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies) tapBlock:^(id obj) {
        [weakImageV setImageWithUrl:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies) tapBlock:nil];
    }];
    
    //Action
    __weak typeof(self) weakSelf = self;
    [alertV addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleCancel handler:nil]];
    [alertV addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [weakSelf sendPhoneCodeWithCaptcha:textF.text phoneCodeButton:sender];
    }]];
 
    //弹出
    [alertV presentWithCompletion:^{
        [textF becomeFirstResponder];
    }];
}

//发送手机验证码
- (void)sendPhoneCodeWithCaptcha:(NSString *)captcha phoneCodeButton:(PhoneCodeButton *)sender {
    if (captcha.length == 0) {
        [NSObject showHudTipStr:@"请输入图形验证码"];
        return;
    }
    
    sender.enabled = NO;
    NSMutableDictionary *params = @{@"phone": _myRegister.phone,
                                    @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]],
                                    @"j_captcha":captcha}.mutableCopy;
    
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/generate_phone_code" withParams:params withMethodType:Post autoShowError:captcha.length > 0 andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        } else {
            [sender invalidateTimer];
            [NSObject showError:error];
        }
    }];
    
}

#pragma mark - Button Actions
- (void)sendRegister {
    NSString *tipStr = nil;
    if (![_myRegister.global_key isGK]) {
        tipStr = @"用户名仅支持英文字母、数字、横线(-)以及下划线(_)";
    } else if (_step > 0 && ![_myRegister.confirm_password isEqualToString:_myRegister.password]) {
        tipStr = @"密码输入不一致";
    }
    
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (_methodType == RegisterMethodPhone && _step <= 0) {
        [self.footerBtn startQueryAnimate];
        NSDictionary *gkP = @{@"key": _myRegister.global_key};
        //检测用户名是否已经存在
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/check" withParams:gkP withMethodType:Get andBlock:^(id data, NSError *error) {
            if (!error && [data[@"data"] boolValue]) {      //用户名还未注册
                NSDictionary *phoneCodeP = @{@"phone": _myRegister.phone,
                                             @"verifyCode": _myRegister.code,
                                             @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]],
                                             };
                //检验手机验证码
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/check-verify-code" withParams:phoneCodeP withMethodType:Post andBlock:^(id data, NSError *error) {
                    [weakSelf.footerBtn stopQueryAnimate];
                    if (!error) {
                        //手机验证码通过校验
                        RegisterViewController *vc = [[RegisterViewController alloc] init];
                        vc.methodType = RegisterMethodPhone;
                        vc.myRegister = weakSelf.myRegister;
                        vc.step = 1;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                }];
            } else {        //用户名已注册
                [weakSelf.footerBtn stopQueryAnimate];
                if (!error) {
                    [NSObject showHudTipStr:@"用户名已存在"];
                }
            }
        }];
        
    } else {            //设置密码
        NSMutableDictionary *params = @{@"channel": [Register channel],
                                        @"global_key": _myRegister.global_key,
                                        @"password": [_myRegister.password sha1Str],
                                        @"confirm": [_myRegister.password sha1Str]}.mutableCopy;
        if (_methodType == RegisterMethodEmail) {
            params[@"email"] = _myRegister.email;
        }else{
            params[@"phone"] = _myRegister.phone;
            params[@"code"] = _myRegister.code;
            params[@"country"] = _countryCodeDict[@"iso_code"];
            params[@"phoneCountryCode"] = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
        }
        if (_captchaNeeded) {
            params[@"j_captcha"] = _myRegister.j_captcha;
        }
        [self.footerBtn startQueryAnimate];
        //注册
        [[Coding_NetAPIManager sharedManager] request_Register_V2_WithParams:params andBlock:^(id data, NSError *error) {
            [weakSelf.footerBtn stopQueryAnimate];
            if (data) {
                [self.view endEditing:YES];
                [Login setPreUserEmail:self.myRegister.global_key];//记住登录账号
                [(AppDelegate *)[UIApplication sharedApplication].delegate setupTabViewController];
                if (weakSelf.methodType == RegisterMethodEmail) {
                    [UIAlertController showAlertViewWithTitle:@"欢迎注册 Coding，请尽快去邮箱查收邮件并激活账号。如若在收件箱中未看到激活邮件，请留意一下垃圾邮件箱(T_T)。"];
                }
            } else {
                 [weakSelf refreshCaptchaNeeded];
            }
        }];
    }
}

- (void)gotoServiceTermsVC {
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"service_terms" withExtension:@"html"];
    WebViewController *webVC = [WebViewController webVCWithUrl:path];
    webVC.title = @"服务条款";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)gotoLoginVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goToCountryCodeVC {
    __weak typeof(self) weakSelf = self;
    CountryCodeListViewController *vc = [[CountryCodeListViewController alloc] init];
    vc.selectedBlock = ^(NSDictionary *countryCodeDict) {
        weakSelf.countryCodeDict = countryCodeDict;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender {
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    
    [self showCaptchaAlert:sender];
    
}

#pragma mark - TableView Header Footer And Bottom
- (UIView *)customHeaderView {
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark2];
    headerL.text = self.step > 0 ? @"设置密码" : @"注册";
    [headerV addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kPaddingLeftWidth);
        make.bottom.offset(0);
        make.height.mas_equalTo(42);
    }];
    return headerV;
}

- (UIView *)customFooterView {
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:self.step > 0 ? @"注册" : @"下一步" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth * 2, 50) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    __weak typeof(self) weakSelf = self;
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.email),
                                                              RACObserve(self, myRegister.password),
                                                              RACObserve(self, myRegister.confirm_password),
                                                              RACObserve(self, myRegister.code),
                                                              RACObserve(self, myRegister.j_captcha),
                                                              RACObserve(self, captchaNeeded)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *email,
                                                                NSString *password,
                                                                NSString *confirm_password,
                                                                NSString *code,
                                                                NSString *j_captcha,
                                                                NSNumber *captchaNeeded){
                                                         BOOL enabled;
                                                         if (weakSelf.methodType == RegisterMethodEmail) {
                                                             enabled = (global_key.length > 0 &&
                                                                        password.length > 0 &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        email.length > 0);
                                                         } else if (weakSelf.step > 0){
                                                             enabled = (global_key.length > 0 &&
                                                                        password.length > 0 &&
                                                                        confirm_password.length > 0 &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        (phone.length > 0 && code.length > 0));
                                                         } else {
                                                             enabled = (global_key.length > 0 &&
                                                                        (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                        (phone.length > 0 && code.length > 0));
                                                         }
                                                         return @(enabled);
                                                     }];
    
    UITTTAttributedLabel *lineLabel = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_footerBtn.frame), CGRectGetMaxY(_footerBtn.frame) +15, CGRectGetWidth(_footerBtn.frame), 15)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = kColorDark2;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"点击注册，即同意《Coding 服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr": @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《Coding 服务条款》"]];
    [footerV addSubview:lineLabel];
    return footerV;
}

- (void)configBottomView {
    UIView *bottomView = [[UIView alloc] init];
    UIButton *bottomBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
        [button setTitle:@"已有 Coding 账号？" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(gotoLoginVC) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [bottomView addSubview:bottomBtn];
    [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(bottomView);
        make.height.mas_equalTo(25);
    }];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50 + kSafeArea_Bottom);
    }];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    [self gotoServiceTermsVC];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = _methodType == RegisterMethodEmail ? 3 : _step > 0 ? 2 : 3;
    return _captchaNeeded ? num + 1 : num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    if (_methodType == RegisterMethodEmail) {
        cellIdentifier = (indexPath.row == 3? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                          indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                          kCellIdentifier_Input_OnlyText_Cell_Text);
    }else{
        if (_step > 0) {
            cellIdentifier = (indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                              kCellIdentifier_Input_OnlyText_Cell_Text);
        }else{
            cellIdentifier = (indexPath.row == 2? self.phoneCodeCellIdentifier:
                              indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Phone:
                              kCellIdentifier_Input_OnlyText_Cell_Text);
        }
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.isBottomLineShow = YES;
    
    __weak typeof(self) weakSelf = self;
    if (_methodType == RegisterMethodEmail) {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.global_key = valueStr;
            };
        }else if (indexPath.row == 1){
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell setPlaceholder:@" 邮箱" value:self.myRegister.email];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
                weakSelf.myRegister.email = valueStr;
            };
            cell.editDidEndBlock = ^(NSString *textStr){
                weakSelf.inputTipsView.active = NO;
            };
        }else if (indexPath.row == 2){
            [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.password = valueStr;
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myRegister.j_captcha = valueStr;
            };
        }
    }else{
        if (_step > 0) {
            if (indexPath.row == 0){
                [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.password = valueStr;
                };
            }else if (indexPath.row == 1){
                [cell setPlaceholder:@" 重复密码" value:self.myRegister.password];
                cell.textField.secureTextEntry = YES;
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.confirm_password = valueStr;
                };
            }else{
                [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.j_captcha = valueStr;
                };
            }
        }else{
            if (indexPath.row == 0) {
                [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.global_key = valueStr;
                };
            }else if (indexPath.row == 1){
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                [cell setPlaceholder:@" 手机号码" value:self.myRegister.phone];
                cell.countryCodeL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
                cell.countryCodeBtnClickedBlock = ^(){
                    [weakSelf goToCountryCodeVC];
                };
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.phone = valueStr;
                };
            }else if (indexPath.row == 2){
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
                cell.textValueChangedBlock = ^(NSString *valueStr){
                    weakSelf.myRegister.code = valueStr;
                };
                cell.phoneCodeBtnClickedBlock = ^(PhoneCodeButton *button) {
                    [weakSelf phoneCodeBtnClicked:button];
                };
            }
        }
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

#pragma mark - Getters And Setters
- (TPKeyboardAvoidingTableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Phone];
        [_myTableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        _myTableView.tableHeaderView = [self customHeaderView];
        _myTableView.tableFooterView = [self customFooterView];
    }
    return _myTableView;
}

- (EaseInputTipsView *)inputTipsView {
    if (!_inputTipsView) {
        _inputTipsView = [EaseInputTipsView tipsViewType:EaseInputTipsViewTypeRegister];
        _inputTipsView.valueStr = nil;
        
        __weak typeof(self) weakSelf = self;
        _inputTipsView.selectedStringBlock = ^(NSString *string) {
            [weakSelf.view endEditing:YES];
            weakSelf.myRegister.email = string;
            [weakSelf.myTableView reloadData];
        };
        UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [_inputTipsView setY:CGRectGetMaxX(cell.frame)];
    }
    return _inputTipsView;
}

@end
