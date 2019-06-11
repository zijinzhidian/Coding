//
//  MessageCell.h
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILongPressMenuImageView.h"
#import "PrivateMessage.h"

#define kCellIdentifier_Message @"MessageCell"
#define kCellIdentifier_MessageMedia @"MessageMediaCell"
#define kCellIdentifier_MessageVoice @"MessageVoiceCell"

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

@property(nonatomic, strong)UILongPressMenuImageView *bgImageView;          //可长按的背景图片
@property(nonatomic, strong)UITTTAttributedLabel *contentLabel;             //显示消息内容的文本

/**
 设置消息

 @param curPriMsg 当前消息
 @param prePriMsg 上一条消息
 */
- (void)setCurPriMsg:(PrivateMessage *)curPriMsg andPrePriMsg:(PrivateMessage *)prePriMsg;

/**
 消息cell的高度

 @param obj 当前消息
 @param preObj 上一条消息
 @return cell高度
 */
+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj;

@end

NS_ASSUME_NONNULL_END
