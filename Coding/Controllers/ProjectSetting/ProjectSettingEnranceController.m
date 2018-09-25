//
//  ProjectSettingEnranceController.m
//  Coding
//
//  Created by apple on 2018/8/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectSettingEnranceController.h"

@interface ProjectSettingEnranceController ()

@end

@implementation ProjectSettingEnranceController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView addLineForPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    [vc setValue:self.project forKey:@"project"];
}


@end
