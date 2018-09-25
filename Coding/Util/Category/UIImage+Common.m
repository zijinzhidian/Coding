//
//  UIImage+Common.m
//  Coding
//
//  Created by apple on 2018/5/3.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

#pragma mark - 颜色生成图片
+ (UIImage *)imageWithColor:(UIColor *)aColor {
    return [UIImage imageWithColor:aColor withFrame:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame {
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - 图片压缩为NSData
- (NSData *)dataSmallerThan:(CGFloat)maxLength {
    NSAssert(maxLength > 0, @"maxLength 必须是个大于零的数");
    //先调整 compression（图片质量）进行压缩
    //当 compression 减小到一定程度时，再继续减小，data 的值也不会改变了。这也是之前压缩会进到死循环的原因
    //compressionFixed 之后，再调整 ratio（图片尺寸）
    //percentInStep 是每步压缩的百分比
    //maxLoopCount 表示调整 compression 或者 ratio 的最大迭代次数。
    //因为有 maxLoopCount，所以这是个不能保证结果正确的方法
    static NSInteger maxLoopCount = 5;
    NSInteger loopCount = 0;
    CGFloat compression = 1.0;
    CGFloat ratio = 1.0;
    CGFloat percentInStep = 1.0;
    UIImage *tempImage = self;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    NSUInteger dataLengthBeforeCompression = data.length;
    BOOL compressionFixed = NO;
    DebugLog(@"\n=============================================dataSmallerThan Start");
    while (data.length > maxLength) {
        percentInStep = maxLength / dataLengthBeforeCompression;
        percentInStep = percentInStep < .8? MAX(sqrtf(percentInStep), .3): percentInStep;
        if (!compressionFixed) {
            compression *= percentInStep;
            data = UIImageJPEGRepresentation(tempImage, compression);
            DebugLog(@"\ncompression:\t%.6f\
                     \nloopCount:\t%ld\
                     \npreLength:\t%lu\
                     \ncurLength:\t%lu\
                     \nmaxLength:\t%.f",
                     compression,
                     (long)loopCount,
                     (unsigned long)dataLengthBeforeCompression,
                     (unsigned long)data.length,
                     maxLength);
            if (data.length / (CGFloat)dataLengthBeforeCompression > .99
                || ++loopCount >= maxLoopCount) {
                loopCount = 0;
                compressionFixed = YES;
            }
            dataLengthBeforeCompression = data.length;
        }else{
            ratio = percentInStep;
            // Use NSUInteger to prevent white blank
            CGSize size = CGSizeMake((NSUInteger)(tempImage.size.width * ratio),
                                     (NSUInteger)(tempImage.size.height * ratio));
            UIGraphicsBeginImageContext(size);
            [tempImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
            tempImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            data = UIImageJPEGRepresentation(tempImage, compression);
            DebugLog(@"\nratio:\t%.6f\
                     \nloopCount:\t%ld\
                     \npreLength:\t%lu\
                     \ncurLength:\t%lu\
                     \nmaxLength:\t%.f",
                     ratio,
                     (long)loopCount,
                     (unsigned long)dataLengthBeforeCompression,
                     (unsigned long)data.length,
                     maxLength);
            if (dataLengthBeforeCompression == data.length
                || ++loopCount >= maxLoopCount) {
                break;
            }
            dataLengthBeforeCompression = data.length;
        }
    }
    DebugLog(@"\n=============================================dataSmallerThan End");
    return data;
}

- (NSData *)dataForCodingUpload {
    return [self dataSmallerThan:1024 * 1000];
}

@end
