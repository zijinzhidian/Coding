//
//  ImageSizeManager.m
//  Coding
//
//  Created by apple on 2019/5/23.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "ImageSizeManager.h"

#define kPath_ImageSizeDict @"ImageSizeDict"

#define kImageSizeManager_maxCount 1000
#define kImageSizeManager_resetCount (kImageSizeManager_maxCount/2)

@interface ImageSizeManager ()
@property(nonatomic, strong)NSMutableDictionary *imageSizeDict;
@end

@implementation ImageSizeManager

+ (instancetype)shareManager {
    static ImageSizeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [manager read];
    });
    return manager;
}

#pragma mark - 操作磁盘缓存
- (NSMutableDictionary *)read {
    if (!_imageSizeDict) {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [NSObject pathInCacheDirectory:kPath_ImageSizeDict], kPath_ImageSizeDict];
        _imageSizeDict = [NSMutableDictionary dictionaryWithContentsOfFile:abslutePath];
        if (!_imageSizeDict) {
            _imageSizeDict = [NSMutableDictionary dictionary];
        }
    }
    return _imageSizeDict;
}

- (BOOL)save {
    if (_imageSizeDict) {
        if ([NSObject createDirInCache:kPath_ImageSizeDict]) {
            NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [NSObject pathInCacheDirectory:kPath_ImageSizeDict], kPath_ImageSizeDict];
            return [_imageSizeDict writeToFile:abslutePath atomically:YES];
        }
    }
    return NO;
}


#pragma mark - 操作内存缓存
- (void)saveImage:(NSString *)imagePath size:(CGSize)size {
    if (imagePath && ![_imageSizeDict objectForKey:imagePath]) {
        [_imageSizeDict setObject:[NSNumber numberWithFloat:size.height / size.width] forKey:imagePath];
    }
}

- (CGFloat)sizeOfImage:(NSString *)imagePath {
    CGFloat imageSize = 1;
    NSNumber *sizeValue = [_imageSizeDict objectForKey:imagePath];
    if (sizeValue) {
        imageSize = sizeValue.floatValue;
    }
    return imageSize;
}

- (BOOL)hasSrc:(NSString *)src {
    NSNumber *sizeValue = [_imageSizeDict objectForKey:src];
    BOOL hasSrc = NO;
    if (sizeValue) {
        hasSrc = YES;
    }
    return hasSrc;
}

#pragma mark - Image Size
/**
 根据宽度重新获取宽高等比例尺寸

 @param height_width 宽高比列
 @param originalWidth 宽度
 */
- (CGSize)sizeWithImageH_W:(CGFloat)height_width originalWidth:(CGFloat)originalWidth {
    CGSize reSize = CGSizeZero;
    reSize.width = originalWidth;
    reSize.height = originalWidth * height_width;
    return reSize;
}

- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight {
    CGSize reSize = [self sizeWithImageH_W:[self sizeOfImage:src] originalWidth:originalWidth];
    if (reSize.height > maxHeight) {
        reSize.height = maxHeight;
    }
    return reSize;
}

- (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight {
    CGSize reSize = [self sizeWithImageH_W:(image.size.height/image.size.width) originalWidth:originalWidth];
    if (reSize.height > maxHeight) {
        reSize.height = maxHeight;
    }
    return reSize;
}

- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight minWidth:(CGFloat)minWidth {
    CGSize reSize = [self sizeWithImageH_W:[self sizeOfImage:src] originalWidth:originalWidth];
    CGFloat scale = maxHeight/reSize.height;
    if (scale < 1) {
        reSize = CGSizeMake(reSize.width * scale, reSize.height * scale);
    }
    if (reSize.width < minWidth) {
        reSize.width = minWidth;
    }
    return reSize;
}

@end
