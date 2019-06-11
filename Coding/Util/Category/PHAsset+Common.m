//
//  PHAsset+Common.m
//  Coding
//
//  Created by apple on 2019/5/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "PHAsset+Common.h"

@implementation PHAsset (Common)

- (NSString *)fileName{
    NSString *fileName;
    if ([self respondsToSelector:NSSelectorFromString(@"filename")]) {
        fileName = [self valueForKey:@"filename"];
    }else{
        fileName = [NSString stringWithFormat:@"%@.JPG", [self.localIdentifier componentsSeparatedByString:@"/"].firstObject];
    }
    return fileName;
}

- (UIImage *)loadImage {
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;                 //同步
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;     //高质量的图片
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;                     //图片尺寸和targetSize一致
    imageOptions.networkAccessAllowed = YES;        //允许从iCloud中下载
    
    __block UIImage *assetImage;
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        assetImage = result;
    }];
    return assetImage;
}

- (NSData *)loadImageData {
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;                 //同步
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;     //高质量的图片
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;                     //图片尺寸和targetSize一致
    imageOptions.networkAccessAllowed = YES;        //允许从iCloud中下载
    
    __block NSData *assetData;
    [[PHImageManager defaultManager] requestImageDataForAsset:self options:imageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        assetData = imageData;
    }];
    return assetData;
}

@end
