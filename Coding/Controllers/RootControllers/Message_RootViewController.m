//
//  Message_RootViewController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Message_RootViewController.h"
#import "ConversationViewController.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "ConversationCell.h"
#import "ToMessageCell.h"
#import "PrivateMessages.h"
#import "UnReadManager.h"

@interface Message_RootViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *myTableView;
@property(nonatomic, strong)ODRefreshControl *refreshControl;
@property(nonatomic, strong)PrivateMessages *myPriMsgs;
@property(nonatomic, strong)NSMutableDictionary * notificationDict;
@end

@implementation Message_RootViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    _myPriMsgs = [[PrivateMessages alloc] init];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tweetBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(sendMsgBtnClicked:)] animated:NO];

    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        [tableView registerClass:[ConversationCell class] forCellReuseIdentifier:kCellIdentifier_Conversation];
        [tableView registerClass:[ToMessageCell class] forCellReuseIdentifier:kCellIdentifier_ToMessage];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self) weakSelf = self;
    [_myTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf refreshMore];
    }];
    
    [self.refreshControl beginRefreshing];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

#pragma mark - Request Data
- (void)refresh {
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_UnReadNotificationsWithBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.notificationDict = [NSMutableDictionary dictionaryWithDictionary:data];
            [weakSelf.myTableView reloadData];
            [weakSelf.myTableView configBlankPage:EaseBlankPageTypeMessageList hasData:(weakSelf.myPriMsgs.list.count) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [weakSelf refresh];
            }];
        }
    }];
    [[UnReadManager shareManager] updateUnRead];

    //如果正在加载数据,不往下执行
    if (_myPriMsgs.isLoading) {
        return;
    }

    _myPriMsgs.willLoadMore = NO;
    [self sendRequest_PrivateMessages];
}

- (void)refreshMore {
    if (_myPriMsgs.isLoading || !_myPriMsgs.canLoadMore) {
        return;
    }
    _myPriMsgs.willLoadMore = YES;
    [self sendRequest_PrivateMessages];
}

- (void)sendRequest_PrivateMessages{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakSelf.myPriMsgs configWithObj:data];
            [weakSelf.myTableView reloadData];
            weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myPriMsgs.canLoadMore;
            [weakSelf.myTableView configBlankPage:EaseBlankPageTypeMessageList hasData:(weakSelf.myPriMsgs.list.count > 0) hasError:(error != nil) offsetY:(3 * [ToMessageCell cellHeight]) reloadButtonBlock:^(id sender) {
                [weakSelf refresh];
            }];
        }
    }];
}

#pragma mark - Button Methods
- (void)sendMsgBtnClicked:(id)sender {
    NSLog(@"~~~%ld",_myPriMsgs.list.count);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 3;
    if (_myPriMsgs.list) {
        row += [_myPriMsgs.list count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        ToMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToMessage forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.type = ToMessageTypeAT;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_AT];
                break;
            case 1:
                cell.type = ToMessageTypeComment;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_Comment];
                break;
            default:
                cell.type = ToMessageTypeSystemNotification;
                cell.unreadCount = [_notificationDict objectForKey:kUnReadKey_notification_System];
                break;
        }
        [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75 hasSectionLine:NO];
        return cell;
    } else {
        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Conversation forIndexPath:indexPath];
        PrivateMessage *msg = [_myPriMsgs.list objectAtIndex:indexPath.row - 3];
        cell.curPriMsg = msg;
        [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75 hasSectionLine:NO];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.row < 3) {
        cellHeight = [ToMessageCell cellHeight];
    }else{
        cellHeight = [ConversationCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < 3) {
        
    } else {
        PrivateMessage *curMsg = [_myPriMsgs.list objectAtIndex:indexPath.row - 3];
        User *curFriend = curMsg.friend;
        
        ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
        conversationVC.myPriMsgs = [PrivateMessages priMsgsWithUser:curFriend];
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}

@end
