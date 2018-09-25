//
//  ProjectCount.h
//  Coding
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectCount : NSObject

@property(nonatomic,strong)NSNumber *all, *watched, *created, *joined, *stared, *deploy;
- (void)configWithProjects:(ProjectCount *)projectCount;

@end
