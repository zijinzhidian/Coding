//
//  UIMessageInputView_Media.h
//  Coding
//
//  Created by apple on 2019/5/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UIMessageInputView_MediaState) {
    UIMessageInputView_MediaStateInit,
    UIMessageInputView_MediaStateUploading,             //正在上传中
    UIMessageInputView_MediaStateUploadSucess,          //上传成功
    UIMessageInputView_MediaStateUploadFailed           //上传失败
};

NS_ASSUME_NONNULL_BEGIN

@interface UIMessageInputView_Media : NSObject

@property(nonatomic, strong)PHAsset *curAsset;      //图片资源对象
@property(nonatomic, strong)NSString *assetID;      //资源ID(99D53A1F-FEEF-40E1-8BB3-7DD55A43C8B7/L0/001)
@property(nonatomic, strong)NSString *urlStr;       //图片路径
@property(nonatomic, assign)UIMessageInputView_MediaState state;        //上传状态

+ (instancetype)mediaWithAsset:(PHAsset *)asset urlStr:(nullable NSString *)urlStr;

@end

NS_ASSUME_NONNULL_END
