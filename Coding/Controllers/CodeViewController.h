//
//  CodeViewController.h
//  Coding
//
//  Created by apple on 2018/7/4.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "BaseViewController.h"

@interface CodeViewController : BaseViewController
@property(nonatomic,strong)Project *myProject;
@property(nonatomic,strong)CodeFile *myCodeFile;
@property(nonatomic,assign)BOOL isReadMe;
+ (CodeViewController *)codeVCWithProject:(Project *)project andCodeFile:(CodeFile *)codeFile;
@end
