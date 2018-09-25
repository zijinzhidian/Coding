//
//  ProjectSettingViewController.h
//  Coding
//
//  Created by apple on 2018/8/18.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface ProjectSettingViewController : UITableViewController

@property(nonatomic,strong)Project *project;

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descTextView;
@property (weak, nonatomic) IBOutlet UIImageView *projectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *privateImageView;
@property (weak, nonatomic) IBOutlet UITextField *projectNameF;

@end
