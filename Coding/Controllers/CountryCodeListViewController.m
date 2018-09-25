//
//  CountryCodeListViewController.m
//  Coding
//
//  Created by apple on 2018/5/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CountryCodeListViewController.h"
#import "CountryCodeCell.h"

@interface CountryCodeListViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)UISearchBar *mySearchBar;
@property(nonatomic,strong)NSDictionary *countryCodeListDict, *searchResults;
@property(nonatomic,strong)NSMutableArray *keyList;

@end

@implementation CountryCodeListViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择国家或地区";
    [self setupData];
    
    [self.view addSubview:self.myTableView];
    //由于导航栏不透明且self.view的第一个子视图为UITableView,原点会从导航栏下面开始,导致UITableView超出屏幕导航栏的高度(解决方法:自动布局)
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
}

#pragma mark - Data
- (void)setupData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country_code" ofType:@"plist"];
    _searchResults = _countryCodeListDict = [NSDictionary dictionaryWithContentsOfFile:path];
    [self p_updateKeyList];
}

- (void)p_updateKeyList {
    _keyList = [_searchResults allKeys].mutableCopy;
    [_keyList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isEqualToString:@"#"]) {
            return NSOrderedAscending;
        }else if ([obj2 isEqualToString:@"#"]){
            return NSOrderedDescending;
        }else{
            return [obj1 compare:obj2];
        }
    }];
    //搜索图标
    [_keyList insertObject:UITableViewIndexSearch atIndex:0];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keyList.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchResults[_keyList[section + 1]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CountryCodeCell forIndexPath:indexPath];
    cell.countryCodeDict = _searchResults[_keyList[indexPath.section+ 1]][indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index > 0 ? index - 1 : index;
}

- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keyList;
}

#pragma mark - UITableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerV = [UIView new];
    headerV.backgroundColor = self.myTableView.backgroundColor;
    UILabel *titleL = [UILabel new];
    titleL.font = [UIFont systemFontOfSize:14];
    titleL.textColor = kColorDark2;
    titleL.text = [_keyList[section+ 1] isEqualToString:@"#"]? @"常用": _keyList[section+ 1];
    [headerV addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerV).insets(UIEdgeInsetsMake(0, 15, 0, 15));
    }];
    return headerV;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableDictionary *searchResults = @{}.mutableCopy;
    //去掉两端空格
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //利用空格分组(比如有H K)
    NSArray *searchItems = [strippedStr componentsSeparatedByString:@" "];
    //如果为空结果不变
    if (strippedStr.length == 0) {
        searchResults = _countryCodeListDict.mutableCopy;
    } else {
        //and组合匹配数组
        NSMutableArray *andMatchPredicates = [NSMutableArray array];
        for (NSString *searchString in searchItems) {
            //or组合匹配数组
            NSMutableArray *searchItemsPredicate = [NSMutableArray array];
            
            //左边表达式
            NSExpression *lhs = [NSExpression expressionForKeyPath:@"country"];
            //右边表达式
            NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
            //比较谓词(NSContainsPredicateOperatorType:左边包含右边则返回true   NSCaseInsensitivePredicateOption:不区分大小写)
            NSComparisonPredicate *finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSContainsPredicateOperatorType options:NSCaseInsensitivePredicateOption];
            //添加
            [searchItemsPredicate addObject:finalPredicate];
            
            lhs = [NSExpression expressionForKeyPath:@"country_code"];
            rhs = [NSExpression expressionForConstantValue:searchString];
            finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSContainsPredicateOperatorType options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            lhs = [NSExpression expressionForKeyPath:@"iso_code"];
            rhs = [NSExpression expressionForConstantValue:searchString];
            finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSContainsPredicateOperatorType options:NSCaseInsensitivePredicateOption];
            [searchItemsPredicate addObject:finalPredicate];
            
            //or组合
            NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
            //添加
            [andMatchPredicates addObject:orMatchPredicates];
        }
        //and组合
        NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
        
        for (NSString *key in _countryCodeListDict.allKeys) {
            NSArray *finalList = [_countryCodeListDict[key] filteredArrayUsingPredicate:finalCompoundPredicate];
            if (finalList.count > 0) {
                [searchResults setValue:finalList forKey:key];
            } else {
                [searchResults removeObjectForKey:key];
            }
        }
    }
    _searchResults = searchResults;
    [self p_updateKeyList];
    [self.myTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _myTableView.backgroundColor = kColorTableSectionBg;
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerClass:[CountryCodeCell class] forCellReuseIdentifier:kCellIdentifier_CountryCodeCell];
        _myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        _myTableView.sectionIndexColor = kColorDark2;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        _myTableView.tableFooterView = [[UIView alloc] init];
        _myTableView.tableHeaderView = self.mySearchBar;
        _myTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _myTableView;
}

- (UISearchBar *)mySearchBar {
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc] init];
        _mySearchBar.delegate = self;
        [_mySearchBar sizeToFit];
        _mySearchBar.placeholder = @"国家/地区名称";
    }
    return _mySearchBar;
}

@end
