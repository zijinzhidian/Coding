//
//  Project_RootViewController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Project_RootViewController.h"
#import "UnReadManager.h"
#import "PopMenu.h"
#import "PopFliterMenu.h"
#import "ProjectListView.h"
#import <RDVTabBarController/RDVTabBarController.h>
#import "SearchViewController.h"
#import "NProjectViewController.h"

@interface Project_RootViewController ()<iCarouselDelegate,iCarouselDataSource>

@property(nonatomic,strong)PopMenu *myPopMenu;          //菜单元素视图

@property(nonatomic,strong)PopFliterMenu *myFliterMenu;     //项目分类选择视图
@property(nonatomic,assign)NSInteger selectNum;

@property(nonatomic,strong)UIButton *navButton;             //导航栏项目分类按钮

@property(nonatomic,strong)NSMutableDictionary *myProjectsDict;     //数据(键为当前页面下标,值为数据Projects)

@end

@implementation Project_RootViewController

#pragma mark - Super TabBar
- (void)tabBarItemClicked {
    [super tabBarItemClicked];
    if (self.myCarousel.currentItemView && [self.myCarousel.currentItemView isKindOfClass:[ProjectListView class]]) {
        ProjectListView *listView = (ProjectListView *)self.myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSegmentItems];
    [self setupNavBtn];
    
    _useNewStyle = true;
    _oldSelectedIndex = 0;
    _selectNum = 0;
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];
    _icarouselScrollEnable = NO;
    
    [self.view addSubview:self.myCarousel];
    [self.myCarousel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //刷新项目数据(视图第一次出现时,由于listView为空,不会刷新数据)
    if (self.myCarousel) {
        ProjectListView *listView = (ProjectListView *)self.myCarousel.currentItemView;
        if (listView) {
            [listView refreshToQueyData];
        }
    }
    //刷新项目分类数目
    [self.myFliterMenu refreshMenuData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //更新未读消息角标
    [[UnReadManager shareManager] updateUnRead];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self closeMenu];
    if (self.myFliterMenu.showStatue) {
        [self.myFliterMenu dismissMenu];
    }
}

#pragma mark - Private Actions
- (void)configSegmentItems {
    _segmentItems = @[@"全部项目",@"我创建的",@"我参与的",@"我关注的",@"我收藏的"];
}

- (BOOL)isRoot {
    return [self isMemberOfClass:[Project_RootViewController class]];
}

//设置导航栏按钮
- (void)setupNavBtn {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemClicked:)];
    if ([self isRoot]) {
        self.navigationItem.titleView = self.navButton;
    }
}

//关闭菜单视图
- (void)closeMenu {
    if (self.myPopMenu.isShow) {
        [self.myPopMenu dismissMenu];
    }
}

//关闭项目过滤视图
- (void)closeFliter {
    if (self.myFliterMenu.showStatue) {
        [self.myFliterMenu dismissMenu];
    }
}

//设置导航栏分类按钮文字
- (void)setNavButtonTitle:(NSString *)title {
    CGFloat titleWidth = [title getWidthWithFont:self.navButton.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
    CGFloat imageWidth = 12;
    CGFloat buttonWidth = titleWidth + imageWidth;
    self.navButton.frame = CGRectMake(0, 0, buttonWidth, 30);
    self.navButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
    self.navButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
    [self.navButton setTitle:title forState:UIControlStateNormal];
    [self.navButton setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
}

//根据下标获取项目数据
- (Projects *)projectsWithIndex:(NSUInteger)index {
    ProjectsType type = (index == 0 ? ProjectsTypeAll :
                         index == 1 ? ProjectsTypeCreated :
                         index == 2 ? ProjectsTypeJoined :
                         index == 3 ? ProjectsTypeWatched :
                         index == 4 ? ProjectsTypeStared : ProjectsTypeAll);
    return [Projects projectsWithType:type andUser:nil];
}

#pragma mark - Button Actions
- (void)addItemClicked:(id)sender {
    [self closeFliter];
    if (!self.myPopMenu.isShow) {
        [self.myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
    } else {
        [self closeMenu];
    }
}

- (void)fliterClicked:(UIButton *)sender {
    [self closeMenu];
    if (self.myFliterMenu.showStatue) {
        [self.myFliterMenu dismissMenu];
    } else {
        self.myFliterMenu.selectNum = _selectNum >= 3 ? _selectNum + 1 : _selectNum;
        [self.myFliterMenu showMenuAtView:kKeyWindow];
    }
}

#pragma mark - VC
- (void)goToProject:(Project *)project {
    NProjectViewController *projectVC = [[NProjectViewController alloc] init];
    projectVC.myProject = project;
    [self.navigationController pushViewController:projectVC animated:YES];
}

- (void)goToSearchVC {
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    BaseNavigationController *nav_search = [[BaseNavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:nav_search animated:NO completion:NULL];
}

- (void)goToScanVC {
    [NSObject showCaptchaViewParams:nil];
}

- (void)goToNewProjectVC {
    
}

- (void)goToProjectSquareVC {
    
}

#pragma mark - iCarouselDataSource
- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return _segmentItems.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view {
    //获取数据
    Projects *curPros = [_myProjectsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    //若数据为空则去初始化
    if (!curPros) {
        curPros = [self projectsWithIndex:index];
        [_myProjectsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    
    ProjectListView *listView = (ProjectListView *)view;
    if (listView) {
        [listView setProjects:curPros];
    } else {
        __weak typeof(self) weakSelf = self;
        //初始化
        listView = [[ProjectListView alloc] initWithFrame:carousel.bounds projects:curPros block:^(Project *project) {
            [weakSelf goToProject:project];
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
        //设置搜索框
        if ([self isRoot]) {        //根视图设置,子类不设置
            [listView setSearchBlock:^{
                [weakSelf goToSearchVC];
            } andScanBlock:^{
                [weakSelf goToScanVC];
            }];
        }
        //使用新系列Cell样式
        listView.useNewStyle = _useNewStyle;
        //方法按钮点击
        listView.clickButtonBlock = ^(EaseBlankPageType curType) {
            switch (curType) {
                case EaseBlankPageTypeProject_ALL:
                case EaseBlankPageTypeProject_CREATE:
                case EaseBlankPageTypeProject_JOIN:
                    //创建项目
                    [weakSelf goToNewProjectVC];
                    break;
                case EaseBlankPageTypeProject_WATCHED:
                case EaseBlankPageTypeProject_STARED:
                    //项目广场
                    [weakSelf goToProjectSquareVC];
                    break;
                default:
                    break;
            }
        };
    }
    //设置ScrollersToTop
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        //刷新数据
        ProjectListView *curListView = (ProjectListView *)carousel.currentItemView;
        [curListView refreshToQueyData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

#pragma mark - Getters And Setters
- (iCarousel *)myCarousel {
    if (!_myCarousel) {
        _myCarousel = [[iCarousel alloc] init];
        _myCarousel.dataSource = self;
        _myCarousel.delegate = self;
        _myCarousel.decelerationRate = 1.0;
        _myCarousel.scrollSpeed = 1.0;
        _myCarousel.type = iCarouselTypeLinear;
        _myCarousel.pagingEnabled = YES;
        _myCarousel.clipsToBounds = YES;
        _myCarousel.bounceDistance = 0.2;
    }
    return _myCarousel;
}

- (PopMenu *)myPopMenu {
    if (!_myPopMenu) {
        NSArray *menuItems = @[
                               [MenuItem itemWithTitle:@"项目" iconName:@"pop_Project" index:0],
                               [MenuItem itemWithTitle:@"任务" iconName:@"pop_Task" index:1],
                               [MenuItem itemWithTitle:@"冒泡" iconName:@"pop_Tweet" index:2],
                               [MenuItem itemWithTitle:@"添加好友" iconName:@"pop_User" index:3],
                               [MenuItem itemWithTitle:@"私信" iconName:@"pop_Message" index:4],
                               [MenuItem itemWithTitle:@"两步验证" iconName:@"pop_2FA" index:5],
                               ];
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 44 + kSafeArea_Top, kScreen_Width, kScreen_Height - 44 - kSafeArea_Top) items:menuItems];
        
        __weak typeof(self) weakSelf = self;
        _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem) {
            __strong typeof(weakSelf) strongSelf;
            if (!selectedItem) return;
            switch (selectedItem.index) {
                case 0:
                    [strongSelf goToNewProjectVC];
                    break;
                    
                case 1:
                    break;
                    
                case 2:
                    break;
                    
                case 3:
                    break;
                    
                case 4:
                    break;
                    
                case 5:
                    break;
            }
        };
        
    }
    return _myPopMenu;
}

- (PopFliterMenu *)myFliterMenu {
    if (!_myFliterMenu) {
        _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 44 + kSafeArea_Top, kScreen_Width, kScreen_Height - 44 - kSafeArea_Top) items:nil];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(_myCarousel) weakCarousel = _myCarousel;
        _myFliterMenu.closeBlock = ^{
            [weakSelf closeFliter];
        };
        _myFliterMenu.clickBlock = ^(NSInteger selectNum) {
            if (selectNum == 1000) {    //项目广场
                [weakSelf goToProjectSquareVC];
            } else {            //项目分类
                [weakCarousel scrollToItemAtIndex:selectNum animated:NO];
                weakSelf.selectNum = selectNum;
            }
        };
    }
    return _myFliterMenu;
}

- (UIButton *)navButton {
    if (!_navButton) {
        _navButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navButton setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        _navButton.titleLabel.font = [UIFont systemFontOfSize:kNavTitleFontSize];
        [_navButton addTarget:self action:@selector(fliterClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self setNavButtonTitle:@"全部项目"];
    }
    return _navButton;
}

- (void)setSelectNum:(NSInteger)selectNum {
    _selectNum = selectNum;
    [self setNavButtonTitle:self.segmentItems[self.selectNum]];
}

- (void)setIcarouselScrollEnable:(BOOL)icarouselScrollEnable {
    _icarouselScrollEnable = icarouselScrollEnable;
    self.myCarousel.scrollEnabled = icarouselScrollEnable;
}

@end
