//
//  Tweet_RootViewController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Tweet_RootViewController.h"
#import "BannersView.h"
#import "UIMessageInputView.h"

@interface Tweet_RootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, assign)NSInteger curIndex;

//Banner
@property(nonatomic, strong)BannersView *bannersView;

@property(nonatomic, strong)UIMessageInputView* myMsgInputView;

@end

@implementation Tweet_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor randomColor];
    
    self.myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypePriMsg];
    self.myMsgInputView.isAlwaysShow = YES;
    
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//
//    [self refreshBanner];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //键盘
    if (self.myMsgInputView) {
        [self.myMsgInputView prepareToShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //键盘
    if (self.myMsgInputView) {
        [self.myMsgInputView prepareToDismiss];
    }
}

#pragma mar - Banner
- (void)refreshBanner {
    if (self.curIndex != Tweet_RootViewControllerTypeAll) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!_bannersView) {
        _bannersView = [[BannersView alloc] init];
        
    }
    self.tableView.tableHeaderView = self.bannersView;
    [[Coding_NetAPIManager sharedManager] request_BannersWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.bannersView.curBannerList = data;
        }
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableView Delegate


#pragma mark - Getters And Setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tableView;
}



@end
