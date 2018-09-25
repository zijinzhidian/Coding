//
//  ProjectCount.m
//  Coding
//
//  Created by apple on 2018/5/11.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectCount.h"

@implementation ProjectCount

- (void)configWithProjects:(ProjectCount *)projectCount {
    self.all = projectCount.all;
    self.watched = projectCount.watched;
    self.created = projectCount.created;
    self.joined = projectCount.joined;
    self.stared = projectCount.stared;
    self.deploy = projectCount.deploy;
}

@end
