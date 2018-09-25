//
//  AllSearchDisplayVC.m
//  Coding
//
//  Created by apple on 2018/6/5.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "AllSearchDisplayVC.h"

@interface AllSearchDisplayVC ()<UISearchBarDelegate>

@property(nonatomic,strong)UIView *contentView;     //容器视图
@property(nonatomic,strong)UIScrollView *searchHistoryView;     //搜索历史视图和空白视图

@property(nonatomic,strong)NSArray *titlesArray;        //标题数组
@property(nonatomic,assign)double historyHeight;        //历史记录视图高度

@end

@implementation AllSearchDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _searchHistoryView.delegate = nil;
}

#pragma mark - Private Methods
//初始化搜索历史视图
- (void)initSearchHistoryView {
    if (!_searchHistoryView) {
        _searchHistoryView = [[UIScrollView alloc] init];
        _searchHistoryView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_searchHistoryView];
        self.searchBar.delegate = self;
        [self registerForKeyboardNotifications];
    }
    //移除所有子视图
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //获取历史记录
    NSArray *array = @[];
    if (array.count > 0) {
        
    } else {
        _historyHeight = kScreen_Height - 236 - 64;
        [_searchHistoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kScreen_Width);
            make.height.mas_equalTo(_historyHeight);
        }];
        
    }
}

//注册键盘通知
- (void)registerForKeyboardNotifications {
    //键盘已经出现时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown) name:UIKeyboardDidShowNotification object:nil];
    //键盘将要隐藏时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown {
    
}

- (void)keyboardWillBeHidden {
    
}

#pragma mark - Getters And Setters
- (NSArray *)titlesArray{
    if (!_titlesArray) {
        _titlesArray = @[@"项目", @"任务", @"讨论", @"冒泡", @"文档", @"用户", @"合并请求", @"Pull 请求"];
    }
    return _titlesArray;
}




@end
