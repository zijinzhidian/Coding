//
//  SearchViewController.m
//  Coding
//
//  Created by apple on 2018/5/24.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "SearchViewController.h"
#import "CategorySearchBar.h"
#import "AllSearchDisplayVC.h"

@interface SearchViewController ()
@property(nonatomic,strong)CategorySearchBar *mySearchBar;
@property(nonatomic,strong)AllSearchDisplayVC *searchDisplayVC;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //搜索框
//    [self.navigationController.navigationBar addSubview:self.mySearchBar];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(popToMainVC)];
    //主界面
    if(!_searchDisplayVC) {
        _searchDisplayVC = ({
            AllSearchDisplayVC *searchVC = [[AllSearchDisplayVC alloc] initWithSearchResultsController:nil];
            [searchVC.searchBar sizeToFit];
            self.navigationItem.searchController = searchVC;
            searchVC;
        });
    }
}

- (void)popToMainVC {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Getters
- (CategorySearchBar *)mySearchBar {
    if (!_mySearchBar) {
        _mySearchBar = [[CategorySearchBar alloc] initWithFrame:CGRectMake(20, 7, kScreen_Width - (80 * kScreen_Width / 375), 31)];
        [_mySearchBar setPlaceholder:@" 搜索"];
    }
    return _mySearchBar;
}

@end
