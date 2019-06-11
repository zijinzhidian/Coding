//
//  UIMessageInputView_Media.m
//  Coding
//
//  Created by apple on 2019/5/15.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "UIMessageInputView_Media.h"

@implementation UIMessageInputView_Media

+ (instancetype)mediaWithAsset:(PHAsset *)asset urlStr:(nullable NSString *)urlStr {
    UIMessageInputView_Media *media = [[UIMessageInputView_Media alloc] init];
    media.curAsset = asset;
    media.assetID = asset.localIdentifier;
    media.urlStr = urlStr;
    media.state = urlStr.length > 0 ? UIMessageInputView_MediaStateUploadSucess : UIMessageInputView_MediaStateInit;
    return media;
}

@end
