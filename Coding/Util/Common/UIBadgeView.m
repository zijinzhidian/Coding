//
//  UIBadgeView.m
//  StringByMatch
//
//  Created by apple on 2018/5/17.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIBadgeView.h"

#define kMaxBadgeWidth    100.0            //角标最大宽度
#define kBadgeTextOffset  2.0              //文字偏移量,即文字距离红圈的距离
#define kBadgePading      5.0              //红圈和白圈的距离

@interface UIBadgeView ()

//角标背景颜色
@property(nonatomic,strong)UIColor *badgeBackgroundColor;
//角标字体颜色
@property(nonatomic,strong)UIColor *badgeTextColor;
//角标字体大小
@property(nonatomic,strong)UIFont *badgeTextFont;

@end


@implementation UIBadgeView

#pragma mark - Init
+ (UIBadgeView *)viewWithBadgeTip:(NSString *)badgeValue {
    if (!badgeValue || badgeValue.length == 0) {
        return nil;
    }
    UIBadgeView *badgeV = [[UIBadgeView alloc] init];
    badgeV.frame = [badgeV badgeFrameWithStr:badgeValue];
    badgeV.badgeValue = badgeValue;
    return badgeV;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.badgeValue.length > 0) {
        
        //文字尺寸
        CGSize badgeSize = [self badgeSizeWithStr:_badgeValue];
        //红圈frame
        CGRect badgeBackgroundFrame = CGRectMake(kBadgePading, kBadgePading, badgeSize.width + 2 * kBadgeTextOffset, badgeSize.height + 2 * kBadgeTextOffset);
        //白圈frame
        CGRect badgeBackgroundPaddingFrame = CGRectMake(0, 0, badgeBackgroundFrame.size.width + 2 * kBadgePading, badgeBackgroundFrame.size.height + 2 * kBadgePading);
        
        if ([self badgeBackgroundColor]) {
            //外白色描边
            if (![self.badgeValue isEqualToString:kBadgeTipStr]) {
                //白色外圈
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                if (badgeSize.width > badgeSize.height) {
                    CGFloat circleWidth = badgeBackgroundPaddingFrame.size.height;
                    CGFloat totalWidth = badgeBackgroundPaddingFrame.size.width;
                    CGFloat diffWidth = totalWidth - circleWidth;
                    CGPoint originPoint = badgeBackgroundPaddingFrame.origin;
                    
                    CGRect leftCicleFrame = CGRectMake(originPoint.x, originPoint.y, circleWidth, circleWidth);
                    CGRect centerFrame = CGRectMake(originPoint.x + circleWidth/2, originPoint.y, diffWidth, circleWidth);
                    CGRect rightCicleFrame = CGRectMake(originPoint.x + (totalWidth - circleWidth), originPoint.y, circleWidth, circleWidth);
                    CGContextFillEllipseInRect(context, leftCicleFrame);
                    CGContextFillRect(context, centerFrame);
                    CGContextFillEllipseInRect(context, rightCicleFrame);
                } else {
                    CGContextFillEllipseInRect(context, badgeBackgroundPaddingFrame);
                }
            }
            
            //角标背景色(红色内圈)
            CGContextSetFillColorWithColor(context, self.badgeBackgroundColor.CGColor);
            if (badgeSize.width > badgeSize.height) {
                CGFloat circleWidth = badgeBackgroundFrame.size.height;
                CGFloat totalWidth = badgeBackgroundFrame.size.width;
                CGFloat diffWidth = totalWidth - circleWidth;
                CGPoint originPoint = badgeBackgroundFrame.origin;
                
                CGRect leftCicleFrame = CGRectMake(originPoint.x, originPoint.y, circleWidth, circleWidth);
                CGRect centerFrame = CGRectMake(originPoint.x + circleWidth/2, originPoint.y, diffWidth, circleWidth);
                CGRect rightCicleFrame = CGRectMake(originPoint.x + (totalWidth - circleWidth), originPoint.y, circleWidth, circleWidth);
                CGContextFillEllipseInRect(context, leftCicleFrame);
                CGContextFillRect(context, centerFrame);
                CGContextFillEllipseInRect(context, rightCicleFrame);
            }else{
                CGContextFillEllipseInRect(context, badgeBackgroundFrame);
            }
        }
        
        //绘制文字
        if (![self.badgeValue isEqualToString:kBadgeTipStr]) {
            CGContextSetFillColorWithColor(context, [[self badgeTextColor] CGColor]);
            
            NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [badgeTextStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *badgeTextAttributes = @{
                                                  NSFontAttributeName: [self badgeTextFont],
                                                  NSForegroundColorAttributeName: [self badgeTextColor],
                                                  NSParagraphStyleAttributeName: badgeTextStyle,
                                                  };
            
            [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + kBadgeTextOffset,
                                                     CGRectGetMinY(badgeBackgroundFrame) + kBadgeTextOffset,
                                                     badgeSize.width, badgeSize.height)
                           withAttributes:badgeTextAttributes];
        }
    }
    
}

#pragma mark - Public Actions
//根据角标的值和字体大小获取文字的尺寸size(不是角标的尺寸)
+ (CGSize)badgeSizeWithStr:(NSString *)badgeValue font:(UIFont *)font {
    if (!badgeValue || badgeValue.length == 0) {
        return CGSizeZero;
    }
    
    //根据不同的机型设置字体大小
    if (!font) {
        if (kDevice_Is_iPhone6 || kDevice_Is_iPhone6Plus || kDevice_Is_iPhoneX) {
            font = [UIFont systemFontOfSize:12];
        } else {
            font = [UIFont systemFontOfSize:11];
        }
    }
    
    //获取字体尺寸,高度不变
    CGSize badgeSize = [badgeValue getSizeWithFont:font constrainedToSize:CGSizeMake(kMaxBadgeWidth, 20)];
    
    //若宽度小于高度,则变为圆形
    if (badgeSize.width < badgeSize.height) {
        badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
    }
    
    if ([badgeValue isEqualToString:kBadgeTipStr]) {
        badgeSize = CGSizeMake(4, 4);
    }
    return badgeSize;
}

//根据角标的值获取文字的尺寸size(不是角标的尺寸)
- (CGSize)badgeSizeWithStr:(NSString *)badgeValue {
//    return [UIBadgeView badgeSizeWithStr:badgeValue font:nil];
    return [UIBadgeView badgeSizeWithStr:badgeValue font:self.badgeTextFont];
}

#pragma mark - Private Actions
//设置默认的数据
- (void)commonInitialization {
    self.backgroundColor = [UIColor clearColor];
    self.badgeBackgroundColor = [UIColor colorWithHexString:@"0xFF0000"];
    self.badgeTextColor = [UIColor whiteColor];
    if (kDevice_Is_iPhone6 || kDevice_Is_iPhone6Plus || kDevice_Is_iPhoneX) {
        self.badgeTextFont = [UIFont systemFontOfSize:12];
    } else {
        self.badgeTextFont = [UIFont systemFontOfSize:11];
    }
}

//获取角标的frame
- (CGRect)badgeFrameWithStr:(NSString *)badgeValue {
    CGSize badgeSize = [self badgeSizeWithStr:badgeValue];
    //8 = 2*2(红圈-文字) + 2*2(白圈-红圈)
    CGFloat more = 2 * kBadgePading + 2 * kBadgeTextOffset;
    CGRect badgeFrame = CGRectMake(0, 0, badgeSize.width + more, badgeSize.height + more);
    return badgeFrame;
}

#pragma mark - Setter
- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    self.frame = [self badgeFrameWithStr:badgeValue];
    [self setNeedsDisplay];
}

@end
