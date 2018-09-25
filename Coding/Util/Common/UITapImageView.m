//
//  UITapImageView.m
//  Coding
//
//  Created by apple on 2018/4/19.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UITapImageView.h"

@interface UITapImageView ()
@property(nonatomic,copy)void(^tapAction)(id);
@end

@implementation UITapImageView

- (void)tap {
    if (self.tapAction) {
        self.tapAction(self);
    }
}

- (void)addTapBlock:(void(^)(id obj))tapAction {
    self.tapAction = tapAction;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
}

- (void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage options:(SDWebImageOptions)options tapBlock:(void (^)(id))tapAction {
    [self sd_setImageWithURL:imgUrl placeholderImage:placeholderImage options:options];
    if (tapAction) {
        [self addTapBlock:tapAction];
    }
}

- (void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction {
    [self sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
    if (tapAction) {
        [self addTapBlock:tapAction];
    }
}

@end
