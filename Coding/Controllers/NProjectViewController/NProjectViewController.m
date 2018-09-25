//
//  NProjectViewController.m
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "NProjectViewController.h"
#import "ODRefreshControl.h"
#import "EaseGitButtonsView.h"

#import "ProjectInfoCell.h"
#import "ProjectDescriptionCell.h"
#import "NProjectItemCell.h"

#import "CodeViewController.h"

@interface NProjectViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)ODRefreshControl *refreshControl;
@property(nonatomic,strong)EaseGitButtonsView *gitButtonsView;
@end

@implementation NProjectViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目首页";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [tableView registerClass:[ProjectInfoCell class] forCellReuseIdentifier:kCellIdentifier_ProjectInfoCell];
        [tableView registerClass:[ProjectDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_ProjectDescriptionCell];
        [tableView registerClass:[NProjectItemCell class] forCellReuseIdentifier:kCellIdentifier_NProjectItemCell];
        tableView;
    });
    
    __weak typeof(self) weakSelf = self;
    _gitButtonsView = [[EaseGitButtonsView alloc] init];
    _gitButtonsView.gitButtonClickedBlock = ^(NSInteger index, EaseGitButtonPosition position){
        if (position == EaseGitButtonPositionLeft) {
            [weakSelf actionWithGitBtnIndex:index];
        }else{
            [weakSelf goToUsersWithGitBtnIndex:index];
        }
    };
    [self.view addSubview:_gitButtonsView];
    [_gitButtonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(EaseGitButtonsView_Height);
    }];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshGitButtonsView];
    [self.myTableView reloadData];
}

#pragma mark - Private Actions
//刷新底部按钮视图
- (void)refreshGitButtonsView {
    self.gitButtonsView.curProject = self.myProject;
//    CGFloat gitButtonsViewHeight = 0;
//    if (self.myProject.is_public.boolValue) {
//        gitButtonsViewHeight = CGRectGetHeight(self.gitButtonsView.frame) - 1;
//    }
//    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, gitButtonsViewHeight, 0);
//    self.myTableView.contentInset = insets;
//    self.myTableView.scrollIndicatorInsets = insets;
}

//刷新数据
- (void)refresh {
    if (_myProject.isLoadingDetail) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectDetail_WithObj:_myProject andBlock:^(id data, NSError *error) {
        if (data) {
            weakSelf.myProject = data;
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.myProject.is_public.boolValue ? nil : [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Artboard"] style:UIBarButtonItemStylePlain target:self action:@selector(tweetsBtnClicked)];
            [weakSelf refreshGitButtonsView];
            [weakSelf.myTableView reloadData];
        }
        [weakSelf.refreshControl endRefreshing];
    }];
}

#pragma mark - Public Actions
//克隆项目
- (void)cloneRepo {
    
}

#pragma mark - Button Actions
//项目公告按钮点击事件
- (void)tweetsBtnClicked {
    
}

#pragma mark - GitButtons Actions
- (void)actionWithGitBtnIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    switch (index) {
        case 0: {
            if (!_myProject.isStaring) {
                [[Coding_NetAPIManager sharedManager] request_StarProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf refreshGitButtonsView];
                }];
            }
        }
            break;
            
        case 1: {
            if (!_myProject.isWatching) {
                [[Coding_NetAPIManager sharedManager] request_WatchProject:_myProject andBlock:^(id data, NSError *error) {
                    [weakSelf refreshGitButtonsView];
                }];
            }
        }
            break;
        
        case 2: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"fork将会将此项目复制到您的个人空间，确定要fork吗?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"xxxxxxxx");
            }];
            [alert addAction:sure];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)goToUsersWithGitBtnIndex:(NSInteger)index {
    if (index == 2) {
        
    } else {
        
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_myProject.is_public) {
        return 0;
    } else if (_myProject.is_public.boolValue) {
        return 4;
    } else if (_myProject.current_user_role_id.integerValue <= 75) {
        return 4;
    } else {
        return 6;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = 0;
    if (_myProject.is_public.boolValue) {
        row = (section == 0 ? 2 :
               section == 1 ? 4 :
               section == 2 ? 2 :
               1);
    } else {
        row = (section == 0 ? 2:
               section == 1 ? 1:
               section == 2 ? 2:
               section == 3 ? 2:
               section == 4 ? 4:
               1);
    }
    return row;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ProjectInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectInfoCell forIndexPath:indexPath];
            cell.curProject = _myProject;
            cell.projectBlock = ^(Project *clickedPro){
                [weakSelf gotoPro:clickedPro];
            };
            return cell;
        }else{
            ProjectDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectDescriptionCell forIndexPath:indexPath];
            [cell setDescriptionStr:_myProject.description_mine];
            return cell;
        }
    }else{
        NProjectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_NProjectItemCell forIndexPath:indexPath];
        if (indexPath.section == 1 && indexPath.row == 0) {
            [cell setImageStr:@"project_item_activity" andTitle:@"动态"];
            if (_myProject.un_read_activities_count.integerValue > 0) {
                [cell addTip:_myProject.un_read_activities_count.stringValue];
            }
        }else if (_myProject.is_public.boolValue) {
            [cell setImageStr:(indexPath.section == 1? (indexPath.row == 1? @"project_item_topic":
                                                        indexPath.row == 2? @"project_item_code":
                                                        @"project_item_member"):
                               indexPath.section == 2? (indexPath.row == 0? @"project_item_readme":
                                                        @"project_item_mr_pr"):
                               @"project_item_reading")
                     andTitle:(indexPath.section == 1? (indexPath.row == 1? @"讨论":
                                                        indexPath.row == 2? @"代码":
                                                        @"成员"):
                               indexPath.section == 2? (indexPath.row == 0? @"README":
                                                        @"Pull Request"):
                               @"本地阅读")];
        }else{
            [cell setImageStr:(indexPath.section == 2? (indexPath.row == 0? @"project_item_task":
                                                        @"project_item_taskboard"):
                               indexPath.section == 3? (indexPath.row == 0? @"project_item_topic":
                                                        @"project_item_file"):
                               indexPath.section == 4? (indexPath.row == 0? @"project_item_code":
                                                        indexPath.row == 1? @"project_item_branch":
                                                        indexPath.row == 2? @"project_item_tag":
                                                        @"project_item_mr_pr"):
                               @"project_item_reading")
                     andTitle:(indexPath.section == 2? (indexPath.row == 0? @"任务列表":
                                                        @"任务看板"):
                               indexPath.section == 3? (indexPath.row == 0? @"讨论":
                                                        @"文件"):
                               indexPath.section == 4? (indexPath.row == 0? @"代码浏览":
                                                        indexPath.row == 1? @"分支管理":
                                                        indexPath.row == 2? @"发布管理":
                                                        @"合并请求"):
                               @"本地阅读")];
        }
        [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:52];
        return cell;
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == ([self numberOfSectionsInTableView:_myTableView] - 1) ? 44 : kLine_MinHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat sectionH = 15;
    if (section == 0) {
        sectionH = kLine_MinHeight;
    } else if (!_myProject.is_public.boolValue && (section == 2 || section == 4)) {
        return 50;
    }
    return sectionH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //current_user_role_id = 75 是受限成员，不可访问代码
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [ProjectInfoCell cellHeight]: [ProjectDescriptionCell cellHeightWithObj:_myProject];
    }else{
        cellHeight = [NProjectItemCell cellHeight];
    }
    return cellHeight;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = kColorTableSectionBg;
    if (!_myProject.is_public.boolValue && (section == 2 || section == 4)) {
        UILabel *leftL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark3];
        leftL.text = section == 2 ? @"任务" : @"代码";
        [headerView addSubview:leftL];
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.left.offset(kPaddingLeftWidth);
        }];
        if (section == 4) {
            UILabel *rightL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorLightBlue];
            rightL.text = @"查看 README";
            rightL.userInteractionEnabled = YES;
            __weak typeof(self) weakSelf = self;
            [rightL bk_whenTapped:^{
                [weakSelf goToReadme];
            }];
            [headerView addSubview:rightL];
            [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(leftL);
                make.right.offset(-kPaddingLeftWidth);
            }];
        }
    }
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProjectSetting" bundle:nil];
            UIViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"Entrance"];
            [settingVC setValue:self.myProject forKey:@"project"];    //KVO赋值
            [self.navigationController pushViewController:settingVC animated:YES];
        }
    }
}

#pragma mark - GoTo VC
- (void)goToReadme {
    CodeViewController *codeVC = [CodeViewController codeVCWithProject:self.myProject andCodeFile:nil];
    codeVC.isReadMe = YES;
    [self.navigationController pushViewController:codeVC animated:YES];
}

- (void)gotoPro:(Project *)project {
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
