//
//  ProjectTransferSettingViewController.m
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectTransferSettingViewController.h"
#import "ProjectMemberListViewController.h"

@interface ProjectTransferSettingViewController ()
@property(nonatomic,strong)SDCAlertController *alert;
@property (weak, nonatomic) IBOutlet UIImageView *userIconView;
@property (weak, nonatomic) IBOutlet UILabel *UserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *transferBtn;

@end

@implementation ProjectTransferSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目转让";
    
    [self.userIconView doCircleFrame];
    [self.transferBtn successStyle];
    self.transferBtn.enabled = NO;
}


#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        __weak typeof(self) weakSelf = self;
        ProjectMemberListViewController *vc = [[ProjectMemberListViewController alloc] init];
        [vc setFrame:self.view.bounds project:self.project type:ProMemTypeTaskOwner refreshBlock:nil selectBlock:^(ProjectMember *member) {
            
        } cellBtnBlock:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

@end
