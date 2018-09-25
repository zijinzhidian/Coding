//
//  NProjectViewController.h
//  Coding
//
//  Created by apple on 2018/7/2.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

@interface NProjectViewController : BaseViewController

@property(nonatomic,strong)Project *myProject;

- (void)cloneRepo;

@end
