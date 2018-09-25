//
//  GlowImageView.m
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "GlowImageView.h"

@implementation GlowImageView

- (void)setGlowColor:(UIColor *)glowColor {
    _glowColor = glowColor;
    if (glowColor) {
        [self setupProperty];
    }
}

- (void)setupProperty {

    self.layer.shadowColor = self.glowColor.CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-5, -5, CGRectGetWidth(self.bounds) + 10, CGRectGetHeight(self.bounds) + 10) cornerRadius:(CGRectGetHeight(self.bounds) + 10) / 2.0].CGPath;
    self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.layer.shadowOpacity = 0.5;
    self.layer.masksToBounds = NO;
}

@end
