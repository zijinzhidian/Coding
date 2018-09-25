//
//  MenuButton.m
//  Coding
//
//  Created by apple on 2018/5/10.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "MenuButton.h"
#import "GlowImageView.h"

@interface MenuButton ()
@property(nonatomic,strong)GlowImageView *iconImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MenuItem *menuItem;
@end

@implementation MenuButton

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame menuItem:(MenuItem *)menuItem {
    self = [super initWithFrame:frame];
    if (self) {
        self.menuItem = menuItem;
        
        CGSize imageSize = menuItem.icomImage.size;
        if (!kDevice_Is_iPhone6Plus && !kDevice_Is_iPhone6) {
            imageSize = CGSizeMake(imageSize.width * 0.9, imageSize.height * 0.9);
        }
        
        self.iconImageView = [[GlowImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        self.iconImageView.userInteractionEnabled = NO;
        [self.iconImageView setImage:menuItem.icomImage forState:UIControlStateNormal];
        self.iconImageView.glowColor = menuItem.glowColor;
        self.iconImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.iconImageView.bounds));
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame) + 20, CGRectGetWidth(self.bounds), 20)];
        self.titleLabel.textColor = kColorDark4;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = menuItem.title;
        CGPoint center = self.titleLabel.center;
        center.x = CGRectGetMidX(self.bounds);
        self.titleLabel.center = center;
        [self addSubview:self.titleLabel];
        
    }
    return self;
}

#pragma mark - Private Actions
- (void)popBegin {
    self.alpha = 0.7;
    
//    [self pop_removeAllAnimations];
//    //播放缩放动画
//    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
//    scaleAnimation.springBounciness = 20;   //0-20
//    scaleAnimation.springSpeed = 20;        //0-20
//    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
//    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
//    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
    
}

- (void)disMissCompleted:(void(^)(BOOL finished))completed {
    self.alpha = 1.0;
    if (completed) {
        completed(YES);
    }
    
//    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
//    scaleAnimation.springBounciness = 16;    //0-20
//    scaleAnimation.springSpeed = 14;         //0-20
//    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
//    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
//    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
//        if (completed) {
//            completed(finished);
//        }
//    };
//    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self popBegin];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    //previousLocationInView:记录的是前一个坐标值
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self]) &&
        !CGRectContainsPoint(self.bounds, [touch previousLocationInView:self])) {
        [self popBegin];
    }else if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]) &&
              CGRectContainsPoint(self.bounds, [touch previousLocationInView:self])){
        [self disMissCompleted:NULL];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self disMissCompleted:^(BOOL finished) {
            //回调
            if (self.didSelectedItemCompleted) {
                self.didSelectedItemCompleted(self.menuItem);
            }
        }];
    } else {
        [self disMissCompleted:NULL];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self disMissCompleted:NULL];
}

@end
