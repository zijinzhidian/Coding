//
//  PHAsset+Common.h
//  Coding
//
//  Created by apple on 2019/5/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (Common)

/**
 文件名
 */
- (NSString *)fileName;

/**
 获取PHAsset对象中的图片
 */
- (UIImage *)loadImage;

/**
 获取PHAsset对象中的二进制图片数据
 */
- (NSData *)loadImageData;

@end

NS_ASSUME_NONNULL_END
