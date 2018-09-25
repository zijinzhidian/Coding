//
//  SwipeBetweenViewController.m
//  Coding
//
//  Created by apple on 2018/5/8.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "SwipeBetweenViewController.h"
#import "EasePageViewController.h"
#import "SMPageControl.h"

//customizeable buttonContainer attributes
CGFloat X_BUFFER = 52.0;                    //两侧边距

//customizeable button attributes
CGFloat BUTTON_HEIGHT = 35.0;                                       //按钮高度
#define BUTTON_WIDTH  ([UIScreen mainScreen].bounds.size.width/3)   //按钮宽度

//customizeable pageControl attributes
CGFloat PAGE_Y_BUFFER = 32.0;
CGFloat PAGE_HEIGHT = 5.0;

@interface SwipeBetweenViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

@property(nonatomic,assign)NSInteger currentPageIndex;      //当前页码下标
@property(nonatomic,assign)BOOL isPageScrollingFlag;        //是否正在滑动
@property(nonatomic,strong)UIScrollView *pageScrollView;

@property(nonatomic,strong)UIScrollView *buttonContainer;   //导航栏上面按钮的包含视图
@property(nonatomic,strong)SMPageControl *pageControl;      //导航栏上面的分页视图

@property(nonatomic,strong)UIViewController *p_displayingViewController;    //当前显示的控制器

@end

@implementation SwipeBetweenViewController
@synthesize viewControllerArray;
@synthesize pageController;
@synthesize buttonText;
@synthesize navigationView;

#pragma mark - Init
+ (instancetype)newSwipeBetweenViewControllers {
    EasePageViewController *pageController = [[EasePageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    return [[SwipeBetweenViewController alloc] initWithRootViewController:pageController];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    viewControllerArray = [[NSMutableArray alloc] init];
    self.currentPageIndex = 0;
    self.isPageScrollingFlag = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!pageController) {
        [self setupPageViewController];
        [self setupSegmentButtons];
        [self updateNavigationViewWithPercentX:self.currentPageIndex];
    }
}

#pragma mark - Private Actions
- (void)setupPageViewController {
    //判断最上面的子控制器是否为分页控制器
    if ([self.topViewController isKindOfClass:[UIPageViewController class]]) {
        pageController = (UIPageViewController *)self.topViewController;
        pageController.delegate = self;
        pageController.dataSource = self;
        //设置当前显示的控制器
        [pageController setViewControllers:@[[viewControllerArray firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        [self syncScrollView];
    }
}

- (void)syncScrollView {
    for (UIView *view in pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
            /*1.scrollsToTop:点击状态栏视图滚动到顶部
              2.当有多个滚动视图时,他们默认都有scroll to top功能,所以触摸状态栏时,系统无法判断是使哪个滚动视图回到顶部
              3.如果当前页面有多个滚动视图的话,要确保只有一个滚动视图scrollsToTop的值为YES
             */
            self.pageScrollView.scrollsToTop = NO;
        }
    }
}

- (void)setupSegmentButtons {
    NSInteger numControllers = [viewControllerArray count];
    //设置buttonText默认值
    if (!buttonText) {
        buttonText = [[NSArray alloc]initWithObjects: @"first",@"second",@"third",@"fourth",@"etc",@"etc",@"etc",@"etc",nil];
    }
    navigationView = [[UIView alloc] initWithFrame:CGRectMake(X_BUFFER, 0, self.view.frame.size.width - 2 * X_BUFFER, self.navigationBar.frame.size.height)];
    
    //buttonContainer
    CGRect frameTemp = navigationView.bounds;
    frameTemp.size.height = BUTTON_HEIGHT;
    _buttonContainer = [[UIScrollView alloc] initWithFrame:frameTemp];
    _buttonContainer.scrollsToTop = NO;
    [navigationView addSubview:_buttonContainer];
    
    //buttons
    CGFloat containerWidth = CGRectGetWidth(_buttonContainer.frame);
    CGFloat containerHeight = CGRectGetHeight(_buttonContainer.frame);   //35
    for (int i = 0; i < numControllers; i++) {
        //居中显示
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((containerWidth - BUTTON_WIDTH) / 2 + BUTTON_WIDTH * i, 0, BUTTON_WIDTH, containerHeight)];
        [_buttonContainer addSubview:button];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:kNavTitleFontSize];
        [button setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //pageControl
    _pageControl = ({
        SMPageControl *pageControl = [[SMPageControl alloc] init];
        pageControl.userInteractionEnabled = NO;
        pageControl.backgroundColor = [UIColor clearColor];
        pageControl.pageIndicatorImage = [UIImage imageNamed:@"nav_page_unselected"];
        pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"nav_page_selected"];
        pageControl.frame = CGRectMake(0, PAGE_Y_BUFFER, CGRectGetWidth(navigationView.frame), PAGE_HEIGHT);
        pageControl.numberOfPages = numControllers;
        pageControl.currentPage = 0;
        pageControl;
    });
    [navigationView addSubview:_pageControl];
    
    pageController.navigationController.navigationBar.topItem.titleView = navigationView;
}

- (void)updateNavigationViewWithPercentX:(CGFloat)percentX {
    //floorf(x):对一个数进行下舍入,即小于等于x,且与x最接近的整数
    NSInteger nearestPage = floor(percentX + 0.5);   //相当于四舍五入
    _pageControl.currentPage = nearestPage;
    
    NSArray *buttons = [_buttonContainer subviews];
    if (buttons.count > 0) {
        //核心动画
        [buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat distanceTp_percentX = percentX - idx;
            [button setCenter:CGPointMake(_buttonContainer.center.x - distanceTp_percentX * BUTTON_WIDTH, _buttonContainer.center.y)];              //每个按钮的偏移
            button.alpha = MAX(0, 1.0 - ABS(distanceTp_percentX));      //每个按钮的透明度
        }];
    }
}

//根据控制器获取当前下表标
- (NSInteger)indexOfController:(UIViewController *)viewController {
    for (int i = 0; i < viewControllerArray.count; i++) {
        if (viewController == [viewControllerArray objectAtIndex:i]) {
            return i;
        }
    }
    return NSNotFound;
}

#pragma mark - Button Actions
- (void)tapSegmentButtonAction:(UIButton *)button {
    
    if (!self.isPageScrollingFlag) {
        
        NSInteger tempIndex = self.currentPageIndex;
        __weak typeof(self) weakSelf = self;
        if (button.tag > tempIndex) {    //right
            
            for (int i = (int)tempIndex + 1; i <= button.tag; i++) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.currentPageIndex = i;
                    }
                }];
            }
            
        } else if (button.tag < tempIndex) {    //left
            
            for (int i = (int)tempIndex - 1; i >= button.tag; i--) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.currentPageIndex = i;
                    }
                }];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat percentX = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger currentPageIndex = self.currentPageIndex;
    if (_p_displayingViewController) {
        currentPageIndex = [self indexOfController:_p_displayingViewController];
    }
    percentX += currentPageIndex - 1;
    [self updateNavigationViewWithPercentX:percentX];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
}

#pragma mark - UIPageViewController DataSource
//当前界面的上一个界面，该代理在手势操作时便触发（轻微滑动），并且应该是有某种缓存机制，同一界面的第二次手势操作不触发
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    _p_displayingViewController = viewController;
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    
    index--;
    return [viewControllerArray objectAtIndex:index];
    
}

//当前界面的下一个界面，机理同上
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    _p_displayingViewController = viewController;
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound || index == viewControllerArray.count - 1) {
        return nil;
    }
    
    index ++;
    return [viewControllerArray objectAtIndex:index];
}

#pragma mark - UIPageViewController Delegate
//跳转动画完成时触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    _p_displayingViewController = nil;
    if (completed) {
        //pageViewController虽然是个数组,但始终只包含一个对象
        self.currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
    }
}


#pragma mark - Getters And Setters
- (UIViewController *)curViewController {
    if (self.viewControllerArray.count > self.currentPageIndex) {
        return [self.viewControllerArray objectAtIndex:self.currentPageIndex];
    } else {
        return nil;
    }
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex {
    _currentPageIndex = currentPageIndex;
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (UIView *aView in [obj.view subviews]) {
            if ([aView isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)aView setScrollsToTop:idx == currentPageIndex];
            }
        }
    }];
}

@end
