//
//  ProjectAdvancedSettingViewController.m
//  Coding
//
//  Created by apple on 2018/8/22.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectAdvancedSettingViewController.h"
#import "ProjectDeleteAlertControllerVisualStyle.h"

@interface ProjectAdvancedSettingViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)SDCAlertController *alert;
@end

@implementation ProjectAdvancedSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"删除项目";
    
    self.tableView.tableFooterView = [[UIView alloc] init];

}

- (void)showDeleteAlertWithType:(VerifyType)type {
    if (self.alert) {       //正在显示
        return;
    }
    
    NSString *title, *message, *placeHolder;
    if (type == VerifyTypePassword) {
        title = @"需要验证密码";
        message = @"这是一个危险的操作，请提供登录密码确认！";
        placeHolder = @"请输入密码";
    }else if (type == VerifyTypeTotp){
        title = @"需要动态验证码";
        message = @"这是一个危险操作，需要进行身份验证！";
        placeHolder = @"请输入动态验证码";
    }else{          //未知类型，不处理
        return;
    }
    
    self.alert = [SDCAlertController alertControllerWithTitle:title message:message preferredStyle:SDCAlertControllerStyleAlert];
    
    //UI
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 240, 30)];
    passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    passwordTextField.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6].CGColor;
    passwordTextField.layer.borderWidth = 1;
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.placeholder = placeHolder;
    passwordTextField.delegate = self;
    passwordTextField.secureTextEntry = (type == VerifyTypePassword);
    [self.alert.contentView addSubview:passwordTextField];
    
    //Style
    self.alert.visualStyle = [[ProjectDeleteAlertControllerVisualStyle alloc] init];
    
    NSDictionary* passwordViews = NSDictionaryOfVariableBindings(passwordTextField);
    [_alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[passwordTextField]-(>=14)-|" options:0 metrics:nil views:passwordViews]];
    
    //按钮
    @weakify(self);
    [self.alert addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
    }]];
    [self.alert addAction:[SDCAlertAction actionWithTitle:@"确定" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        @strongify(self);
        self.alert = nil;
        NSString *passCode = passwordTextField.text;
        if (passCode.length > 0) {
            //删除项目
            [[Coding_NetAPIManager sharedManager] request_DeleteProject_WithObj:self.project passCode:passCode type:type andBlock:^(Project *data, NSError *error) {
                if (!error) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }]];
    [self.alert presentWithCompletion:^{
        [passwordTextField becomeFirstResponder];
    }];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [[Coding_NetAPIManager sharedManager] request_VerifyTypeWithBlock:^(VerifyType type, NSError *error) {
            if (!error) {
                [self showDeleteAlertWithType:type];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
