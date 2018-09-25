//
//  SettingTextViewController.m
//  Coding
//
//  Created by apple on 2018/8/25.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "SettingTextViewController.h"
#import "SettingTextCell.h"

@interface SettingTextViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSString *myTextValue;
@end

@implementation SettingTextViewController

#pragma mark - Init
+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block {
    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
    vc.title = title;
    vc.textValue = textValue;
    vc.doneBlock = block;
    vc.settingType = SettingTypeOnlyText;
    return vc;
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.myTableView];
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _myTextValue = [_textValue mutableCopy];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(doneBtnClicked:)] animated:YES];
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, myTextValue)] reduce:^id (NSString *newTextValue){
        @strongify(self);
        if ([self.textValue isEqualToString:newTextValue]) {
            return @(NO);
        } else if (self.settingType != SettingTypeOnlyText && newTextValue.length <= 0) {
            return @(NO);
        }
        return @(YES);
    }];
    
    if (self.settingType != SettingTypeOnlyText) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)];
    }
}

#pragma mark - Button Methods
- (void)doneBtnClicked:(id)sender {
    if (self.doneBlock) {
        self.doneBlock(self.myTextValue);
    }
    if (self.navigationController.viewControllers.count <= 1) {
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dismissSelf {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SettingText forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell setTextValue:_textValue andTextChangBlock:^(NSString *textValue) {
        weakSelf.myTextValue = textValue;
    }];
    cell.textField.placeholder = self.placeholderStr;
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _myTableView.backgroundColor = kColorTableSectionBg;
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        [_myTableView registerClass:[SettingTextCell class] forCellReuseIdentifier:kCellIdentifier_SettingText];
    }
    return _myTableView;
}


@end
