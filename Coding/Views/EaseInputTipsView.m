//
//  EaseInputTipsView.m
//  Coding
//
//  Created by apple on 2018/4/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "EaseInputTipsView.h"
#import "Login.h"
#import <UIKit/UIKit.h>

@interface EaseInputTipsView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSArray *dataList, *loginAllList, *emailAllList;

@end

@implementation EaseInputTipsView

#pragma mark - Init
+ (instancetype)tipsViewType:(EaseInputTipsViewType)type {
    return [[self alloc] initWithTipsType:type];
}

- (instancetype)initWithTipsType:(EaseInputTipsViewType)type {
    CGFloat paddingWidth = 0.0;
    self = [super initWithFrame:CGRectMake(paddingWidth, 0, kScreen_Width - 2 * paddingWidth, 120)];
    if (self) {
        
        [self addRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];
        self.clipsToBounds = YES;
        [self addSubview:self.myTableView];
        
        _type = type;
        _active = YES;
        
        self.translatesAutoresizingMaskIntoConstraints = false;
        
        
    }
    return self;
}

#pragma mark - Actions
- (void)refresh {
    [self.myTableView reloadData];
    self.hidden = self.dataList.count <= 0 || !_active;
}


- (NSArray *)emailList {
    
    if (_valueStr.length <= 0) {
        return nil;
    }
    
    //123456789@qq.com
    NSRange range_AT = [_valueStr rangeOfString:@"@"];
    if (range_AT.location == NSNotFound) {
        return nil;
    }
    
    NSString *nameStr = [_valueStr substringToIndex:range_AT.location];
    NSString *tipStr = [_valueStr substringFromIndex:range_AT.location + range_AT.length];
    
    NSMutableArray *list = [NSMutableArray array];
    [[self emailAllList] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:tipStr].location != NSNotFound || tipStr.length <= 0) {
            [list addObject:[nameStr stringByAppendingFormat:@"@%@",obj]];
        }
    }];
    return list;
}

- (NSArray *)loginList {
    
    if (_valueStr.length <= 0) {
        return nil;
    }
    
    
    NSString *tipStr = [_valueStr copy];
    NSMutableArray *list = [NSMutableArray array];
    [[self loginAllList] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:tipStr].location != NSNotFound) {
            [list addObject:obj];
        }
    }];
    return list;
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *cellIdentifier = @"EaseInputTipsViewCell";
    NSInteger laberTag = 99;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kLoginPaddingLeftWidth, 0, kScreen_Width - 2 * kLoginPaddingLeftWidth, 35)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = kColorDark7;
        label.tag = laberTag;
        [cell.contentView addSubview:label];
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:laberTag];
    label.text = _dataList[indexPath.row];
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedStringBlock && self.dataList.count > indexPath.row) {
        self.selectedStringBlock(self.dataList[indexPath.row]);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth hasSectionLine:NO];
}

#pragma mark - Getters And Setters
- (UITableView *)myTableView {
    if (!_myTableView) {
        
        _myTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _myTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        _myTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.estimatedRowHeight = 0;
        _myTableView.estimatedSectionHeaderHeight = 0;
        _myTableView.estimatedSectionFooterHeight = 0;
        _myTableView.tableFooterView = [UIView new];
        
    }
    return _myTableView;
}

- (NSArray *)loginAllList {
    if (!_loginAllList) {
        
        _loginAllList = [[Login readLoginDataList] allKeys];
        
    }
    return _loginAllList;
}

- (NSArray *)emailAllList {
    if (!_emailAllList) {
        
        NSString *emailListStr = @"qq.com, 163.com, gmail.com, 126.com, sina.com, sohu.com, hotmail.com, tom.com, sina.cn, foxmail.com, yeah.net, vip.qq.com, 139.com, live.cn, outlook.com, aliyun.com, yahoo.com, live.com, icloud.com, msn.com, 21cn.com, 189.cn, me.com, vip.sina.com, msn.cn, sina.com.cn";
        _emailAllList = [emailListStr componentsSeparatedByString:@", "];
        
    }
    return _emailAllList;
}

- (void)setActive:(BOOL)active {
    _active = active;
    self.hidden = self.dataList.count <= 0 || !_active;
}

- (void)setValueStr:(NSString *)valueStr {
    _valueStr = [valueStr lowercaseString];
    
    if (_valueStr.length <= 0) {
        self.dataList = nil;
    } else if ([_valueStr rangeOfString:@"@"].location == NSNotFound) {
        self.dataList = (_type == EaseInputTipsViewTypeLogin) ? [self loginList] : nil;
    } else {
        self.dataList = [self emailList];
    }
    
    [self refresh];
    
}

@end
