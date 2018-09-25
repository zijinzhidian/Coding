//
//  ProjectMemberListViewController.m
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectMemberListViewController.h"
#import "MemberCell.h"
#import "ODRefreshControl.h"
#import "Login.h"
#import "SettingTextViewController.h"

@interface ProjectMemberListViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchResultsUpdating,SWTableViewCellDelegate>

@property(nonatomic,strong)UISearchController *mySearchController;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)ODRefreshControl *myRefreshControl;

@property(nonatomic,assign)CGRect viewFrame;
@property(nonatomic,strong)Project *myProject;
@property(nonatomic,assign)ProMemType type;
@property(nonatomic,copy)ProjectMemberBlock selectBlock;
@property(nonatomic,copy)ProjectMemberListBlock refreshBlock;
@property(nonatomic,copy)ProjectMemberCellBtnBlock cellBtnBlock;

@property(nonatomic,strong)NSMutableArray *searchResults;       //搜索结果数据源
@property(nonatomic,strong)NSNumber *selfRoleType;              //权限类型

@end

@implementation ProjectMemberListViewController

#pragma mark - Request Data
- (void)refresh {
    if (self.myProject.isLoadingMember) {
        return;
    }
    
    if (!self.myMemberArray || self.myMemberArray.count == 0) {
        [self.view beginLoading];
    }
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectMembers_WithObj:self.myProject andBlock:^(id data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.myMemberArray = data;
            [weakSelf.myTableView reloadData];
            if (weakSelf.refreshBlock) {
                weakSelf.refreshBlock(data);
            }
        }
        [weakSelf.view configBlankPage:EaseBlankPageTypeView hasData:(weakSelf.myMemberArray.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refresh];
        }];
    }];
}

- (void)refreshFirst {
    if (!self.myMemberArray) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目成员";
    
    //self.view
    _viewFrame.origin.y = 0.0;
    self.view = [[UIView alloc] initWithFrame:_viewFrame];
    
    //tableview
    [self.view addSubview:self.myTableView];
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //search controller
    self.definesPresentationContext = YES;
    
    //refresh control
    self.myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [self.myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    //first refresh
    if (self.type == ProMemTypeAT) {
        __weak typeof(self) weakSelf = self;
        //首先尝试加载本地数据,无数据的情况才去服务器请求
        id resultData = [NSObject loadResponseWithPath:[self.myProject localMembersPath]];
        resultData = [resultData objectForKey:@"list"];
        
        if (resultData) {
            NSMutableArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"ProjectMemer"];
            weakSelf.myMemberArray = resultA;
            [weakSelf.myTableView reloadData];
        } else {
            [self refreshFirst];
        }
    } else {
        [self refreshFirst];
    }
    
}

#pragma mark - Public Methods
- (void)setFrame:(CGRect)frame project:(Project *)project type:(ProMemType)type refreshBlock:(ProjectMemberListBlock)refreshBlock selectBlock:(ProjectMemberBlock)selectBlock cellBtnBlock:(ProjectMemberCellBtnBlock)cellBtnBlock{
    _viewFrame = frame;
    _myProject = project;
    _refreshBlock = refreshBlock;
    _selectBlock = selectBlock;
    _cellBtnBlock = cellBtnBlock;
    _type = type;
    _myMemberArray = nil;
}

#pragma mark - Private Methods
//获取编辑按钮数组
- (NSArray *)rightButtonsWithObj:(ProjectMember *)mem {
    NSMutableArray *rightUtilityButtons = @[].mutableCopy;
    BOOL canAlias = self.selfRoleType.integerValue > 90;    //是否可以编辑备注名
    BOOL canDelete = (canAlias && self.selfRoleType.integerValue > mem.type.integerValue);  //是否可以设置和删除
    if (canAlias) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xE5E5E5"] icon:[UIImage imageNamed:@"member_cell_edit_alias"]];
    }
    if (canDelete) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"0xF0F0F0"] icon:[UIImage imageNamed:@"member_cell_edit_type"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"member_cell_edit_remove"]];
    }
    return rightUtilityButtons;
}

//编辑备注名
- (void)editAliasOfMember:(ProjectMember *)curMember {
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMember) weakMember = curMember;
    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"设置备注" textValue:curMember.editAlias doneBlock:^(NSString *textValue) {
        weakMember.editAlias = textValue;
        [[Coding_NetAPIManager sharedManager] request_EditAliasOfMember:weakMember inProject:weakSelf.myProject andBlock:^(id data, NSError *error) {
            if (data) {
                weakMember.alias = weakMember.editAlias;
                [weakSelf.myTableView reloadData];
            }
        }];
    }];
    vc.placeholderStr = @"备注名";
    [self.navigationController pushViewController:vc animated:YES];
}

//编辑成员权限
- (void)editTypeOfMember:(ProjectMember *)curMember {
    if (_myProject.is_public.boolValue) {
        [NSObject showHudTipStr:@"公开项目不开放项目权限"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak typeof(curMember) weakMember = curMember;
    
}

//移除成员
- (void)removeOfMember:(ProjectMember *)curMember {
    
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mySearchController.active) {
        return self.searchResults.count;
    } else {
        return self.myMemberArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MemberCell forIndexPath:indexPath];
    ProjectMember *curMember;
    if (self.mySearchController.active) {
        curMember = self.searchResults[indexPath.row];
    } else {
        curMember = self.myMemberArray[indexPath.row];
    }
    cell.curMember = curMember;
    if (self.type == ProMemTypeTaskOwner) {
        [cell setRightUtilityButtons:[self rightButtonsWithObj:curMember] WithButtonWidth:[MemberCell cellHeight]];
        cell.delegate = self;
    }
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:60];
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MemberCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    
}

#pragma mark - SWTableViewCellDelegate
//轻扫时隐藏其它的编辑按钮
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

//是否能编辑
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state {
    if (state == kCellStateRight) {
        BOOL canAlias = self.selfRoleType.integerValue >= 90;
        return canAlias;
    }
    return YES;
}

//编辑按钮点击事件
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    ProjectMember *mem = [(MemberCell *)cell curMember];
    if (index == 0) {      //修改备注
        [self editAliasOfMember:mem];
    } else if (index == 1) {    //修改权限
        [self editTypeOfMember:mem];
    } else if (index == 2) {    //移除成员
        [UIAlertController showSheetViewWithTitle:@"移除该成员后,他将不再显示在项目中" message:nil buttonTitles:nil destructiveTitle:@"确认移除" cancelTitle:@"取消" didDismissBlock:^(NSInteger index) {
            if (index == 0) {
                [self removeOfMember:mem];
            }
        }];
    }
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //初始化搜索列表
    self.searchResults = self.myMemberArray.mutableCopy;
    //去掉所有的前后空格
    NSString *strippedStr = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    //以空格为分隔符切割成数组
    NSArray *searchItems = nil;
    if (strippedStr.length > 0) {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"user.name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        //        global_key field matching
        lhs = [NSExpression expressionForKeyPath:@"user.global_key"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        //        pinyin
        lhs = [NSExpression expressionForKeyPath:@"user.pinyinName"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    self.searchResults = [self.searchResults filteredArrayUsingPredicate:finalCompoundPredicate].mutableCopy;
    
    [self.myTableView reloadData];
    
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _myTableView.backgroundColor = [UIColor clearColor];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        _myTableView.tableHeaderView = self.mySearchController.searchBar;
        [_myTableView registerClass:[MemberCell class] forCellReuseIdentifier:kCellIdentifier_MemberCell];
    }
    return _myTableView;
}

- (UISearchController *)mySearchController {
    if (!_mySearchController) {
        _mySearchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _mySearchController.searchBar.placeholder = @"昵称/个性后缀";
        _mySearchController.dimsBackgroundDuringPresentation = NO;
        _mySearchController.searchResultsUpdater = self;
    }
    return _mySearchController;
}

- (void)setMyMemberArray:(NSMutableArray *)myMemberArray {
    _myMemberArray = myMemberArray;
    for (ProjectMember *men in _myMemberArray) {
        if ([men.user_id isEqualToNumber:[Login curLoginUser].id]) {
            _selfRoleType = men.type;
        }
    }
}

@end
