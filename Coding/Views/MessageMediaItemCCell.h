//
//  MessageMediaItemCCell.h
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLImageView.h"

#define kCCellIdentifier_MessageMediaItem @"MessageMediaItemCCell"
#define kCCellIdentifier_MessageMediaItem_Single @"MessageMediaItemCCell_Single"

NS_ASSUME_NONNULL_BEGIN

@interface MessageMediaItemCCell : UICollectionViewCell

@property(nonatomic, strong)NSObject *curObj;
@property(nonatomic, strong)YLImageView *imageView;

@property(nonatomic, copy)void(^refreshMessageMediaCCellBlock)(CGFloat diff);

/**
 获取图片、声音、html尺寸
 */
+ (CGSize)ccellSizeWithObj:(NSObject *)obj;

/**
 获取猴子表情尺寸
 */
+ (CGSize)monkeyCcellSize;

@end

NS_ASSUME_NONNULL_END
