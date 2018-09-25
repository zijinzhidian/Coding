//
//  ProjectListView.m
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectListView.h"
#import "CategorySearchBar.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "ProjectListCell.h"
#import "ProjectListTaCell.h"
#import "ProjectAboutMeListCell.h"
#import "ProjectAboutOthersListCell.h"
#import "ProjectPublicListCell.h"
#import "Login.h"

static NSString *const kTitleKey = @"kTitleKey";
static NSString *const kValueKey = @"kValueKey";

@interface ProjectListView ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SWTableViewCellDelegate>

@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UISearchBar *mySearchBar;
@property(nonatomic,strong)ODRefreshControl *myRefreshControl;

@property(nonatomic,strong)Projects *myProjects;
@property(nonatomic,strong)NSMutableArray *dataList;    //用kTitleKey和kValueKey两个键保存

@property(nonatomic,copy)void(^searchBlock)(void);      //搜索按钮点击回调
@property(nonatomic,copy)void(^scanBlock)(void);        //扫一扫按钮点击回调
@property(nonatomic,copy)ProjectListViewBlock block;

@property(nonatomic,assign)BOOL isHeaderClosed;         //是否取消头部视图
@property(nonatomic,assign)BOOL isNewerVersionAvailable;    //是否有需要更新的版本

@end

@implementation ProjectListView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight {
    self = [super initWithFrame:frame];
    if (self) {
        _myProjects = projects;
        _block = block;
        
        //添加tableView
        [self addSubview:self.myTableView];
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        //设置tableView的偏移量
        if (tabBarHeight != 0 && projects.type < ProjectsTypeTaProject) {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
            self.myTableView.contentInset = insets;
            self.myTableView.scrollIndicatorInsets = insets;
        }
        
        //设置tableView的头部搜索框
        if (projects.type < ProjectsTypeToChoose || projects.type == ProjectsTypeAllPublic) {
            self.myTableView.tableHeaderView = nil;
        } else {
            self.myTableView.tableHeaderView = self.mySearchBar;
        }
        
        //下拉刷新控件
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refreshToQueyData) forControlEvents:UIControlEventValueChanged];
        
        //上拉刷新控件
        __weak typeof(self) weakSelf = self;
        [self.myTableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf refreshMore];
        }];
        
        if (self.myProjects.list.count > 0) {
            [self.myTableView reloadData];
        } else {
            [self sendRequest];
        }
    }
    return self;
}

#pragma mark - Public Actions
- (void)setProjects:(Projects *)projects {
    _myProjects = projects;
    [self setupDataList];
    [self refreshUI];
}

- (void)refreshUI {
    [self.myTableView reloadData];
    [self refreshFirst];
}

- (void)refreshToQueyData {
    if (!_myProjects.isLoading) {
        [self sendRequest];
        [self p_checkIfNewVersionTip];
    }
}

- (void)setSearchBlock:(void(^)(void))searchBlock andScanBlock:(void(^)(void))scanBlock {
    _searchBlock = searchBlock;
    _scanBlock = scanBlock;
    if (searchBlock || scanBlock) {
        self.mySearchBar = ({
            MainSearchBar *searchBar = [MainSearchBar new];
            searchBar.delegate = self;
            searchBar.placeholder = @"搜索";
            [searchBar setPlaceholderColor:kColorDarkA];
            [searchBar setSearchIcon:[UIImage imageNamed:@"icon_search_searchbar"]];
            [searchBar sizeToFit];
            [searchBar.scanBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            searchBar;
        });
        self.myTableView.tableHeaderView = self.mySearchBar;
    } else {
        self.myTableView.tableHeaderView = nil;
    }
}

- (void)tabBarItemClicked {
    if (self.myTableView.contentOffset.y > 0) {      //回到顶部
        [self.myTableView setContentOffset:CGPointZero animated:YES];
    } else if (!self.myRefreshControl.isAnimating) {        //刷新数据
        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refreshToQueyData];
    }
}

#pragma mark - Private Actions
//设置字典数据
- (void)setupDataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [_dataList removeAllObjects];
    if (_myProjects.type < ProjectsTypeToChoose) {
        NSMutableArray *list = _myProjects.list;
        if (list.count > 0) {
            [list sortUsingComparator:^NSComparisonResult(Project *obj1, Project *obj2) {
                return (obj1.pin.integerValue < obj1.pin.integerValue);
            }];
            [_dataList addObject:@{kTitleKey: @"全部项目",
                                   kValueKey: list}];
        }
    } else {
        NSMutableArray *list = [self updateFilteredContentForSearchString:self.mySearchBar.text];
        if (list.count > 0) {
            [list sortUsingComparator:^NSComparisonResult(Project *obj1, Project *obj2) {
                return (obj1.pin.integerValue < obj1.pin.integerValue);
            }];
            [_dataList addObject:@{kTitleKey: @"搜索项目",
                                   kValueKey: list}];
        }
    }
}

//第一次刷新
- (void)refreshFirst {
    //_myProjects.list存放的是项目数据,若为空则代表是第一次请求数据
    if (_myProjects && !_myProjects.list) {
        [self performSelector:@selector(refreshToQueyData) withObject:nil afterDelay:0.3];
    }
}

//刷新更多数据
- (void)refreshMore {
    //若正在加载数据或没有更多数据可加载,停止动画
    if (self.myProjects.isLoading || !_myProjects.canLoadMore) {
        [self.myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    self.myProjects.willLoadMore = YES;
    [self sendRequest];
}

//请求数据
- (void)sendRequest {
    if (_myProjects.list.count <= 0) {
        [self beginLoading];
    }
    //都先隐藏~后续根据数据状态显示~
    self.blankPageView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_Projects_WithObj:_myProjects andBlock:^(Projects *data, NSError *error) {
        [weakSelf.myRefreshControl endRefreshing];
        [weakSelf endLoading];
        [weakSelf.myTableView.infiniteScrollingView stopAnimating];
        
        if (data) {
            [weakSelf.myProjects configWithProjects:data];
            [weakSelf setupDataList];
            [weakSelf.myTableView reloadData];
        }
        EaseBlankPageType blankPageType;
        if (weakSelf.myProjects.type < ProjectsTypeTaProject
            || [weakSelf.myProjects.curUser.global_key isEqualToString:[Login curLoginUser].global_key]) {
            //再做细分  全部,创建,参与,关注,收藏
            switch (weakSelf.myProjects.type) {
                case ProjectsTypeAll:
                    blankPageType = EaseBlankPageTypeProject_ALL;
                    break;
                case ProjectsTypeCreated:
                case ProjectsTypeCreatedPrivate:
                case ProjectsTypeCreatedPublic:
                    blankPageType = EaseBlankPageTypeProject_CREATE;
                    break;
                case ProjectsTypeJoined:
                    blankPageType = EaseBlankPageTypeProject_JOIN;
                    break;
                case ProjectsTypeWatched:
                    blankPageType = EaseBlankPageTypeProject_WATCHED;
                    break;
                case ProjectsTypeStared:
                    blankPageType = EaseBlankPageTypeProject_STARED;
                    break;
                default:
                    blankPageType = EaseBlankPageTypeProject;
                    break;
            }
        }else{
            blankPageType = EaseBlankPageTypeProjectOther;
        }
        [weakSelf configBlankPage:blankPageType hasData:(weakSelf.myProjects.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakSelf refreshToQueyData];
        }];
        
        //空白页按钮事件
        self.blankPageView.clickButtonBlock=^(EaseBlankPageType curType) {
            weakSelf.clickButtonBlock(curType);
        };
        
        weakSelf.myTableView.showsInfiniteScrolling = weakSelf.myProjects.canLoadMore;
    }];
    
}

//根据搜索文字过滤项目
- (NSMutableArray *)updateFilteredContentForSearchString:(NSString *)searchString {
    
    NSMutableArray *searchResults = self.myProjects.list;
    
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *searchItems = nil;
    if (strippedStr.length > 0) {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    for (NSString *searchString in searchItems) {
        
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"owner_user_name"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
        
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    [searchResults filterUsingPredicate:finalCompoundPredicate];
    return searchResults;
    
}

//检查当前版本更新
- (void)p_checkIfNewVersionTip {
    if ([self p_needToCheckIfNewVersion]) {
        NSString *appStoreCountry = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if ([appStoreCountry isEqualToString:@"150"]) {
            appStoreCountry = @"eu";
        } else if ([[appStoreCountry stringByReplacingOccurrencesOfString:@"[A-Za-z]{2}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, 2)] length]) {
            appStoreCountry = @"us";
        }
        __weak typeof(self) weakSelf = self;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/%@/lookup?id=%@", appStoreCountry, @(923676989)]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (!error && data) {
                    /*
                     NSJSONReadingMutableContainers:返回可变容器,NSMutableDictionary或NSMutableArray
                     NSJSONReadingMutableLeaves:返回可变的字符串,NSMutableString
                     NSJSONReadingAllowFragments: 返回允许JSON字符串最外层既不是NSArray也不是NSDictionary，但必须是有效的JSON Fragment.可以是如 "10"
                     */
                    NSDictionary *result = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"results"] lastObject];
                    //商店最新版本
                    NSString *latestVersion = result[@"version"];
                    //设备支持的最低版本
                    NSString *minimumSupportedOSVersion = result[@"minimumOsVersion"];
                    if (latestVersion && minimumSupportedOSVersion) {
                        //NSNumericSearch:按照字符串里面的数字作为比较依据
                        BOOL osVersionSupported = [[UIDevice currentDevice].systemVersion compare:minimumSupportedOSVersion options:NSNumericSearch] != NSOrderedAscending;
                        BOOL isNewerVersionAvailable = [kVersion_Coding compare:latestVersion options:NSNumericSearch] == NSOrderedAscending;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.isNewerVersionAvailable = osVersionSupported && isNewerVersionAvailable;
                        });
                    }
                }
            }];
            [task resume];
        });
    }
}

//是否需要去检测新版本
- (BOOL)p_needToCheckIfNewVersion {
     return (!_isHeaderClosed && (_useNewStyle && _myProjects.type == ProjectsTypeAll) && !self.isNewerVersionAvailable);
}

//是否需要去显示新版本提示
- (BOOL)p_needToShowVersionTip {
    return (!_isHeaderClosed && (_useNewStyle && _myProjects.type == ProjectsTypeAll) && self.isNewerVersionAvailable);
}

- (NSString *)titleForSection:(NSUInteger)section {
    if (section < self.dataList.count) {
        return [[self.dataList objectAtIndex:section] valueForKey:kTitleKey];
    }
    return nil;
}

- (NSArray *)valueForSection:(NSUInteger)section {
    if (section < self.dataList.count) {
        return [[self.dataList objectAtIndex:section] valueForKey:kValueKey];
    }
    return nil;
}

#pragma mark - Button Actions
- (void)scanBtnClicked {
    if (self.scanBlock) {
        self.scanBlock();
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self valueForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Project *curPro = [[self valueForSection:indexPath.section] objectAtIndex:indexPath.row];
    if (_useNewStyle) {
        if (_myProjects.type < ProjectsTypeWatched) {
            ProjectAboutMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutMeListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectsTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }else if (_myProjects.type==ProjectsTypeWatched||_myProjects.type==ProjectsTypeStared){
            ProjectAboutOthersListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectAboutOthersListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectsTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }else if (_myProjects.type==ProjectsTypeAllPublic){
            ProjectPublicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProjectPublicListCell" forIndexPath:indexPath];
            [cell setProject:curPro hasSWButtons:self.myProjects.type == ProjectsTypeAll?YES:NO hasBadgeTip:YES hasIndicator:NO];
            cell.delegate = self;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }
        else{
            ProjectListTaCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectListTaCell forIndexPath:indexPath];
            cell.project = curPro;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpaceAndSectionLine:kPaddingLeftWidth];
            return cell;
        }
    }else
    {
        if (_myProjects.type < ProjectsTypeTaProject) {
            ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
            if (self.myProjects.type == ProjectsTypeToChoose) {
                [cell setProject:curPro hasSWButtons:NO hasBadgeTip:NO hasIndicator:NO];
            }else{
                [cell setProject:curPro hasSWButtons:YES hasBadgeTip:YES hasIndicator:YES];
            }
            cell.delegate = self;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }else{
            ProjectListTaCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectListTaCell forIndexPath:indexPath];
            cell.project = curPro;
            [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self p_needToShowVersionTip] ? 40 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_useNewStyle) {
        if (_myProjects.type < ProjectsTypeTaProject) {
            return kProjectAboutMeListCellHeight;
        }else if (_myProjects.type==ProjectsTypeAllPublic){
            return kProjectPublicListCellHeight;
        }else{
            return [ProjectListTaCell cellHeight];
        }
    }else{
        return (_myProjects.type < ProjectsTypeTaProject)?[ProjectListCell cellHeight]:[ProjectListTaCell cellHeight];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self p_needToShowVersionTip]) {
        //头部视图
        UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        headerV.backgroundColor = [UIColor colorWithHexString:@"0xECF9FF"];
        //关闭按钮
        __weak typeof(self) weakSelf = self;
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"button_tip_close"] forState:UIControlStateNormal];
        [closeBtn bk_addEventHandler:^(id sender) {
            weakSelf.isHeaderClosed = YES;
        } forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(headerV);
            make.width.equalTo(closeBtn.mas_height);
        }];
        //提示视图
        UIImageView *noticeV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_tip_notice"]];
        noticeV.contentMode = UIViewContentModeCenter;
        [headerV addSubview:noticeV];
        [noticeV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(headerV);
            make.width.equalTo(noticeV.mas_height);
        }];
        //提示文字
        UILabel *tipL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor colorWithHexString:@"0x136BFB"]];
        tipL.adjustsFontSizeToFitWidth = YES;
        tipL.minimumScaleFactor = 0.5;
        tipL.userInteractionEnabled = YES;
        tipL.text = @"立即升级最新 Coding 客户端";
        [tipL bk_whenTapped:^{
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppUrl] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppUrl]];
                
            }
        }];
        [headerV addSubview:tipL];
        [tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(headerV);
            make.left.equalTo(noticeV.mas_right);
            make.right.equalTo(closeBtn.mas_left);
        }];
        return headerV;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_block) {
        _block([[self valueForSection:indexPath.section] objectAtIndex:indexPath.row]);
    }
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    Project *curPro = [[self valueForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(curPro) weakPro = curPro;
    [[Coding_NetAPIManager sharedManager] request_Project_Pin:curPro andBlock:^(id data, NSError *error) {
        if (data) {
            weakPro.pin = @(!weakPro.pin.boolValue);
            [weakSelf setupDataList];
            [weakSelf.myTableView reloadData];
        }
    }];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (_searchBlock) {
        _searchBlock();
    }
    return _searchBlock == nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self setupDataList];
    [self.myTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self setupDataList];
    [self.myTableView reloadData];
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] init];
        _myTableView.backgroundColor = [UIColor clearColor];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.separatorStyle = UITableViewScrollPositionNone;
        _myTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        [_myTableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
        [_myTableView registerClass:[ProjectListTaCell class] forCellReuseIdentifier:kCellIdentifier_ProjectListTaCell];
        [_myTableView registerClass:[ProjectAboutMeListCell class] forCellReuseIdentifier:@"ProjectAboutMeListCell"];
        [_myTableView registerClass:[ProjectAboutOthersListCell class] forCellReuseIdentifier:@"ProjectAboutOthersListCell"];
        [_myTableView registerClass:[ProjectPublicListCell class] forCellReuseIdentifier:@"ProjectPublicListCell"];
    }
    return _myTableView;
}


- (UISearchBar *)mySearchBar {
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc] init];
        _mySearchBar.delegate = self;
        [_mySearchBar sizeToFit];
        [_mySearchBar setPlaceholder:@"项目名称/创建人"];
        [_mySearchBar setPlaceholderColor:kColorDarkA];
        [_mySearchBar setSearchIcon:[UIImage imageNamed:@"icon_search_searchbar"]];
    }
    return _mySearchBar;
}


- (void)setIsHeaderClosed:(BOOL)isHeaderClosed {
    _isHeaderClosed = isHeaderClosed;
    [self.myTableView reloadData];
}

- (void)setIsNewerVersionAvailable:(BOOL)isNewerVersionAvailable {
    _isNewerVersionAvailable = isNewerVersionAvailable;
    [self.myTableView reloadData];
}

- (void)setUseNewStyle:(BOOL)useNewStyle {
    _useNewStyle = useNewStyle;
    if (_useNewStyle && _myProjects.type == ProjectsTypeAllPublic) {
        [self.myTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(@44);
        }];
    }
    [self.myTableView reloadData];
    [self p_checkIfNewVersionTip];
}

@end
