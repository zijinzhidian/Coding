//
//  PopFliterMenu.m
//  Coding
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "PopFliterMenu.h"
#import "XHRealTimeBlur.h"
#import "ProjectCount.h"
#import <pop/POP.h>

static CGFloat const kProjectCell_Height = 50;
static CGFloat const kLineCell_Height = 30.5;

static NSString *const kTableViewCellIdentifier = @"tableViewCellIdentifier";

@interface PopFliterMenu ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *items;
@property(nonatomic,strong)XHRealTimeBlur *realTimeBlur;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)ProjectCount *pCount;      //项目数目
@end

@implementation PopFliterMenu

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = @[@{@"all":@""},@{@"created":@""},@{@"joined":@""},@{@"watched":@""},@{@"stared":@""}].mutableCopy;
        self.pCount = [[ProjectCount alloc] init];
        self.showStatue = NO;
        [self setup];
    }
    return self;
}

#pragma mark - Private Actions
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.clipsToBounds = YES;
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.1;
    _realTimeBlur.disMissDuration = 0.2;
    _realTimeBlur.hasTapGestureEnable = YES;
    
    __weak typeof(self) weakSelf = self;
    _realTimeBlur.willShowBlurViewcomplted = ^{
        //tableView显示动画
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @0.0;
        alphaAnimation.toValue = @1.0;
        alphaAnimation.duration = 0.3;
        [weakSelf.tableView pop_addAnimation:alphaAnimation forKey:@"alphaAnimationS"];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^{
        //tableview隐藏动画
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @1.0;
        alphaAnimation.toValue = @0.0;
        alphaAnimation.duration = 0.2;
        [weakSelf.tableView pop_addAnimation:alphaAnimation forKey:@"alphaAnimationE"];
    };
    
    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
        [weakSelf removeFromSuperview];
    };
    
    _tableView =({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
        tableView;
    });
    [self addSubview:_tableView];
    
    //tableView底部空白区域,15为tableView偏移量
    int contentHeight = 15 + kProjectCell_Height * 6 + kLineCell_Height * 2;
    if ((kScreen_Height - 44 - kSafeArea_Top) > contentHeight) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, contentHeight , kScreen_Width, kScreen_Height - 44 - kSafeArea_Top - contentHeight)];
        contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
        [contentView addGestureRecognizer:tapGestureRecognizer];
    }
    
}

//获取cell标题
- (NSString *)formatTitleStr:(NSDictionary *)aDic {
    NSMutableString *convertStr = [NSMutableString string];
    NSString *keyStr = [[aDic allKeys] firstObject];
    if ([keyStr isEqualToString:@"all"]) {
        [convertStr appendString:@"全部项目"];
    }else if ([keyStr isEqualToString:@"created"]) {
        [convertStr appendString:@"我创建的"];
    }else if ([keyStr isEqualToString:@"joined"]) {
        [convertStr appendString:@"我参与的"];
    }else if ([keyStr isEqualToString:@"watched"]) {
        [convertStr appendString:@"我关注的"];
    }else if ([keyStr isEqualToString:@"stared"]) {
        [convertStr appendString:@"我收藏的"];
    }
    if ([[aDic objectForKey:keyStr] length] > 0) {
        [convertStr appendString:[NSString stringWithFormat:@" (%@)",[aDic objectForKey:keyStr]]];
    }
    return [convertStr copy];
}

//更新数据源
- (void)updateDataSource:(ProjectCount*)pCount {
    _items = @[@{@"all":[pCount.all stringValue]},@{@"created":[pCount.created stringValue]},@{@"joined":[pCount.joined  stringValue]},@{@"watched":[pCount.watched stringValue]},@{@"stared":[pCount.stared stringValue]}].mutableCopy;
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    if (_closeBlock) {
        _closeBlock();
    }
}

#pragma mark - Public Actions
//将菜单显示到某个视图上
- (void)showMenuAtView:(UIView *)containerView {
    _showStatue = YES;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
    [_tableView reloadData];
}

//隐藏视图
- (void)dismissMenu {
    _showStatue = NO;
    [_realTimeBlur disMiss];
}

//刷新数据
- (void)refreshMenuData {
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectsCatergoryAndCounts_WithObj:_pCount andBlock:^(ProjectCount *data, NSError *error) {
        if (data) {
            [weakSelf.pCount configWithProjects:data];
            [weakSelf updateDataSource:weakSelf.pCount];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //加1是用于显示分割线
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 2 + 1;
            break;
            
        case 2:
            return 1 + 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:titleLabel];
    if (indexPath.section == 0) {     
        titleLabel.textColor = (indexPath.row == _selectNum) ? kColorBrandBlue : kColor222;
        titleLabel.text = [self formatTitleStr:[_items objectAtIndex:indexPath.row]];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [titleLabel removeFromSuperview];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width - 40, 0.5)];
            lineView.backgroundColor = kColorCCC;
            [cell.contentView addSubview:lineView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            NSInteger num = [tableView numberOfRowsInSection:0];
            titleLabel.textColor = (indexPath.row + num == _selectNum) ? kColorBrandBlue : kColor222;
            titleLabel.text = [self formatTitleStr:[_items objectAtIndex:indexPath.row - 1 + num]];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [titleLabel removeFromSuperview];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width - 40, 0.5)];
            lineView.backgroundColor = kColorCCC;
            [cell.contentView addSubview:lineView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            [titleLabel setX:45];
            titleLabel.textColor = [UIColor colorWithHexString:@"0x727f8d"];
            titleLabel.text = @"项目广场";
            UIImageView *projectSquareIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25-8, 16, 16)];
            projectSquareIcon.image = [UIImage imageNamed:@"fliter_square"];
            [cell.contentView addSubview:projectSquareIcon];
        }
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((indexPath.row == 0) && (indexPath.section == 1)) || ((indexPath.row == 0) && (indexPath.section == 2)) ? kLineCell_Height : kProjectCell_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        _selectNum = indexPath.row;
        [self dismissMenu];
        if (_clickBlock) {
            _clickBlock(self.selectNum);
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (_closeBlock) {
                _closeBlock();
            }
            return;
        }
        _selectNum = indexPath.row - 1 + [tableView numberOfRowsInSection:0];
        [self dismissMenu];
        if (_clickBlock) {
            _clickBlock(self.selectNum);
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (_closeBlock) {
                _closeBlock();
            }
            return;
        }
        if (_closeBlock) {
            _closeBlock();
        }
        if (_clickBlock) {
            _clickBlock(1000);
        }
    }
}

@end
