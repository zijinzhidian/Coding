//
//  ValueListViewController.m
//  Coding
//
//  Created by apple on 2018/8/27.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ValueListViewController.h"

@interface ValueListViewController ()

@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UIView *tipView;


@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,strong)NSArray *dataList;
@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,assign)ValueListType type;
@property(nonatomic,copy)IndexSelectedBlock selectBlock;

@end

@implementation ValueListViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
}

#pragma mark - Public Methods
- (void)setTitle:(NSString *)title valueList:(NSArray *)list defaultSelectIndex:(NSInteger)index type:(ValueListType)type selectBlock:(IndexSelectedBlock)selectBlock {
    self.titleStr = title;
    self.dataList = list;
    self.selectedIndex = index;
    self.type = type;
    self.selectBlock = selectBlock;
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.backgroundColor = kColorTableSectionBg;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
    }
    return _myTableView;
}

@end
