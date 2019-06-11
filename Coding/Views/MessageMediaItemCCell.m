//
//  MessageMediaItemCCell.m
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "MessageMediaItemCCell.h"

#define kMessageCell_ContentWidth (0.6 * kScreen_Width)

@implementation MessageMediaItemCCell

- (void)setCurObj:(NSObject *)curObj {
    _curObj = curObj;
    if (!_curObj) {
        return;
    }
    if (!_imageView) {
        _imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_ContentWidth, kMessageCell_ContentWidth)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 6.0;
        [self.contentView addSubview:_imageView];
    }
    
    if ([_curObj isKindOfClass:[UIImage class]]) {
        UIImage *curImage = (UIImage *)_curObj;
        self.imageView.image = curImage;
        [_imageView setSize:[[ImageSizeManager shareManager] sizeWithImage:curImage originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2]];
    } else if ([_curObj isKindOfClass:[HtmlMediaItem class]]) {
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)_curObj;
        NSURL *currentImageURL = [curMediaItem.src urlImageWithCodePathResizeToView:_imageView];
        __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:currentImageURL placeholderImage:kPlaceholderCodingSquareWidth(150.0) completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            HtmlMediaItem *curBlockMediaItem = (HtmlMediaItem *)weakSelf.curObj;
            if (image && [imageURL.absoluteString isEqualToString:currentImageURL.absoluteString]) {
                CGSize imageSize = image.size;
                if (![[ImageSizeManager shareManager] hasSrc:curBlockMediaItem.src]) {
                    [[ImageSizeManager shareManager] saveImage:curBlockMediaItem.src size:imageSize];
                    CGSize reSize = [[ImageSizeManager shareManager] sizeWithImage:image originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
                    if (weakSelf.refreshMessageMediaCCellBlock) {
                        weakSelf.refreshMessageMediaCCellBlock(reSize.height - kMessageCell_ContentWidth);
                    }
                }
            }
        }];
        
        CGSize reSize = CGSizeZero;
        if ([self.reuseIdentifier isEqualToString:kCCellIdentifier_MessageMediaItem_Single]) {
            reSize = [MessageMediaItemCCell monkeyCcellSize];
        } else {
            reSize = [MessageMediaItemCCell ccellSizeWithObj:_curObj];
        }
        [_imageView setSize:reSize];
    }
}

+ (CGSize)ccellSizeWithObj:(NSObject *)obj {
    CGSize itemSize = CGSizeZero;
    if ([obj isKindOfClass:[UIImage class]]) {
        itemSize = [[ImageSizeManager shareManager] sizeWithImage:(UIImage *)obj originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    } else if ([obj isKindOfClass:[VoiceMedia class]]) {
        itemSize = CGSizeMake(kMessageCell_ContentWidth, 40);
    } else if ([obj isKindOfClass:[HtmlMediaItem class]]) {
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        itemSize = [[ImageSizeManager shareManager] sizeWithSrc:curMediaItem.src originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    }
    return itemSize;
}

+ (CGSize)monkeyCcellSize {
    CGFloat width = kScaleFrom_iPhone5_Desgin(100);
    return CGSizeMake(width, width);
}

@end
