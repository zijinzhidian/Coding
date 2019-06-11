//
//  ImageSizeManager.h
//  Coding
//
//  Created by apple on 2019/5/23.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageSizeManager : NSObject

+ (instancetype)shareManager;

#pragma mark - 操作磁盘缓存
- (NSMutableDictionary *)read;
- (BOOL)save;

#pragma mark - 操作内存缓存
/**
 存储宽高比列(size.height/size.width)

 @param imagePath 作为存储的key
 @param size 图片尺寸
 */
- (void)saveImage:(NSString *)imagePath size:(CGSize)size;
/**
 获取宽高比列
 */
- (CGFloat)sizeOfImage:(NSString *)imagePath;
/**
 判断是否缓存了宽高比列

 @param src 查询的key
 */
- (BOOL)hasSrc:(NSString *)src;

#pragma mark - Image Size
- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;
- (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;
- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight minWidth:(CGFloat)minWidth;


@end

NS_ASSUME_NONNULL_END
