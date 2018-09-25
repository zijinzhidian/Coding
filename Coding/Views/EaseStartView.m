//
//  EaseStartView.m
//  Coding
//
//  Created by apple on 2018/5/7.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "EaseStartView.h"

@interface EaseStartView ()
@property(nonatomic,strong)UIImageView *bgImageView, *logoIconView;
@end

@implementation EaseStartView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = kScreen_Bounds;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
