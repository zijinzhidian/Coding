//
//  OTPAuthClock.m
//  Coding
//
//  Created by apple on 2018/4/28.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "OTPAuthClock.h"

@interface OTPAuthClock ()
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSTimeInterval period;
@end

@implementation OTPAuthClock

- (instancetype)initWithFrame:(CGRect)frame period:(NSTimeInterval)period {
    self = [super initWithFrame:frame];
    if (self) {
        self.period = period;
        [self startTimer];
        self.opaque = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive {
    [self startTimer];
    [self redrawTimer:nil];
}
    
- (void)applicationWillResignActive {
    [self invalidate];
}

- (void)redrawTimer:(NSTimer *)timer {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    //fmod(x,y)-->x除以y的余数,比如fmod(9.2, 2)为1.2
    CGFloat mod =  fmod(seconds, self.period);
    CGFloat percent = mod / self.period;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, rect);
    CGFloat midX = CGRectGetMidX(bounds);
    CGFloat midY = CGRectGetMidY(bounds);
    CGFloat radius = midY - 4;
    
    //Draw  bg
    CGContextMoveToPoint(context, midX, midY);
    CGFloat start = -M_PI_2;
    CGFloat end = 2 * M_PI;
    CGFloat sweep = end * percent + start;
    CGContextAddArc(context, midX, midY, radius, start, sweep, 1);
    [[[UIColor blackColor] colorWithAlphaComponent:0.7] setFill];
    CGContextFillPath(context);
    if (percent > .875) {
        CGContextMoveToPoint(context, midX, midY);
        CGContextAddArc(context, midX, midY, radius, start, sweep, 1);
        CGFloat alpha = (percent - .875) / .125;
        [[[UIColor redColor] colorWithAlphaComponent:alpha * 0.5] setFill];
        CGContextFillPath(context);
    }
}

//开始定时器
- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(redrawTimer:) userInfo:nil repeats:YES];
}


//停止定时器
- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self invalidate];
    }
}

@end
