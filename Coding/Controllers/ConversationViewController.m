//
//  ConversationViewController.m
//  Coding
//
//  Created by apple on 2019/5/21.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "ConversationViewController.h"
#import "ODRefreshControl.h"
#import "MessageCell.h"

@interface ConversationViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong)UITableView *myTableView;
@property(nonatomic, strong)ODRefreshControl *refreshControl;
@property(nonatomic, strong)UIMessageInputView *myMsgInputView;
@end

@implementation ConversationViewController

static const NSTimeInterval kPollTimeInterval = 3.0;

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableBG;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        [tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_Message];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self refreshLoadMore:NO];
}

#pragma mark - Refresh
- (void)refreshLoadMore:(BOOL)willLoadMore {
    if (!_myPriMsgs || _myPriMsgs.isLoading) {
        return;
    }
    _myPriMsgs.willLoadMore = willLoadMore;
    if (willLoadMore) {
        if (!_myPriMsgs.canLoadMore) {
            [_refreshControl endRefreshing];
            return;
        } else {
            [_refreshControl beginRefreshing];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        if (data) {
            [weakSelf.myPriMsgs configWithObj:data];
            [weakSelf.myTableView reloadData];
            if (!weakSelf.myPriMsgs.willLoadMore) {
                
            } else {
                
            }
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypePrivateMsg hasData:(weakSelf.myPriMsgs.dataList.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshLoadMore:NO];
        }];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 0;
    if (_myPriMsgs.dataList) {
        row = [_myPriMsgs.dataList count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell;
    //当前信息(倒序读取信息)
    NSUInteger curIndex = _myPriMsgs.dataList.count - 1 - indexPath.row;
    PrivateMessage *curMsg = [_myPriMsgs.dataList objectAtIndex:curIndex];
    
    //上一条信息
    PrivateMessage *preMsg = nil;
    if (curIndex + 1 < _myPriMsgs.dataList.count) {
        preMsg = [_myPriMsgs.dataList objectAtIndex:curIndex + 1];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Message forIndexPath:indexPath];
    [cell setCurPriMsg:curMsg andPrePriMsg:preMsg];
    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrivateMessage *preMessage = nil;
    NSUInteger curIndex = _myPriMsgs.dataList.count - 1 - indexPath.row;
    if (curIndex + 1 < _myPriMsgs.dataList.count) {
        preMessage = [_myPriMsgs.dataList objectAtIndex:curIndex + 1];
    }
    return [MessageCell cellHeightWithObj:[_myPriMsgs.dataList objectAtIndex:curIndex] preObj:preMessage];
}

@end
