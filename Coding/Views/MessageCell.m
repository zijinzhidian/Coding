//
//  MessageCell.m
//  Coding
//
//  Created by apple on 2019/5/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "MessageCell.h"
#import "UITapImageView.h"
#import "Login.h"
#import "MessageMediaItemCCell.h"

#define kMessageCell_FontContent [UIFont systemFontOfSize:15]       //消息字体大小
#define kMessageCell_ContentWidth (kScreen_Width * 0.6)             //消息内容最大宽度
#define kMessageCell_TimeHeight 40.0                                //显示时间的文本高度
#define kMessageCell_UserIconWidth  40.0                            //用户头像尺寸
#define kMessageCell_PaddingWidth 20.0                              //内容的水平方向偏移
#define kMessageCell_Paddingheight 11.0                             //内容的垂直方向偏移

@interface MessageCell ()

@property(nonatomic, strong)PrivateMessage *curPriMsg, *prePriMsg;

@property(nonatomic, strong)UITapImageView *userIconView;       //用户头像

@property(nonatomic, strong)UILabel *timeLabel;                 //时间文本

@end

@implementation MessageCell

#pragma mark - Init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //用户头像
        if (!_userIconView) {
            _userIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_UserIconWidth, kMessageCell_UserIconWidth)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        
        //背景图片
        if (!_bgImageView) {
            _bgImageView = [[UILongPressMenuImageView alloc] initWithFrame:CGRectZero];
            _bgImageView.userInteractionEnabled = YES;
            [self.contentView addSubview:_bgImageView];
        }
        
        //内容文本
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kMessageCell_PaddingWidth, kMessageCell_Paddingheight, 0, 0)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.font = kMessageCell_FontContent;
            _contentLabel.textColor = [UIColor blackColor];
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [_bgImageView addSubview:_contentLabel];
            
        }
    }
    return self;
}

#pragma mark - Public Methods
+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj {
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[PrivateMessage class]]) {
        PrivateMessage *curPriMsg = (PrivateMessage *)obj;
        
        //多媒体信息高度
        CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
        cellHeight += mediaViewHeight;
        
        //文字或声音消息高度
        if ([curPriMsg isVoice]) {    //声音
            cellHeight += kMessageCell_Paddingheight * 2 + 40;
        } else {                      //文字
            CGSize textSize = [curPriMsg.content getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
            cellHeight += textSize.height + kMessageCell_Paddingheight * 4;    //乘以4是因为图片背景和消息内容都有一个kMessageCell_Paddingheight
        }
        
        //添加间距
        if (mediaViewHeight > 0 && curPriMsg.content && curPriMsg.content.length > 0) {
            cellHeight += kMessageCell_Paddingheight;
        }
        
        //显示时间文本高度
        PrivateMessage *prePriMsg = (PrivateMessage *)preObj;
        NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:curPriMsg preMsg:prePriMsg];
        if (displayStr) {
            cellHeight += kMessageCell_TimeHeight;
        }
    }
    return cellHeight;
}


- (void)setCurPriMsg:(PrivateMessage *)curPriMsg andPrePriMsg:(PrivateMessage *)prePriMsg {
    self.curPriMsg = curPriMsg;
    self.prePriMsg = prePriMsg;
    
    //是否是自己发的消息
    BOOL isMyMsg = [curPriMsg.sender.global_key isEqualToString:[Login curLoginUser].global_key];
    //多媒体信息的高度
    CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
    
    if (!_curPriMsg) {
        return;
    }
    
    //时间
    CGFloat curBottomY = 0;
    NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:_curPriMsg preMsg:_prePriMsg];
    if (displayStr) {
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kMessageCell_TimeHeight - 20)/2, kScreen_Width - 2 * kPaddingLeftWidth, 20)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = kColor999;
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_timeLabel];
        }
        _timeLabel.hidden = NO;
        _timeLabel.text = displayStr;
        curBottomY += kMessageCell_TimeHeight;
    } else {
        _timeLabel.hidden = YES;
    }
    
    UIImage *bgImg;         //消息背景图片
    CGSize bgImgViewSize;   //消息背景视图尺寸大小
    CGSize textSize;        //消息内容尺寸大小
    
    //设置消息内容并自适应文本大小
    [_contentLabel setWidth:kMessageCell_ContentWidth];
    _contentLabel.text = curPriMsg.content;
    [_contentLabel sizeToFit];
    
    textSize = _curPriMsg.content.length > 0 ? _contentLabel.size : CGSizeZero;
    
    for (HtmlMediaItem *item in _curPriMsg.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && _curPriMsg.htmlMedia.mediaItems) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    if (mediaViewHeight > 0) {
        //        有图片
        [_contentLabel setY:2*kMessageCell_Paddingheight + mediaViewHeight];
        
        CGFloat contentWidth = [_curPriMsg isSingleBigMonkey]? [MessageMediaItemCCell monkeyCcellSize].width : kMessageCell_ContentWidth;
        bgImgViewSize = CGSizeMake(contentWidth +2*kMessageCell_PaddingWidth,
                                   mediaViewHeight + textSize.height + kMessageCell_Paddingheight*(_curPriMsg.content.length > 0? 3:2));
    } else if ([curPriMsg isVoice]) {
        bgImgViewSize = CGSizeMake(kMessageCell_ContentWidth, 40);
    } else{
        [_contentLabel setY:kMessageCell_Paddingheight];
        
        bgImgViewSize = CGSizeMake(textSize.width +2*kMessageCell_Paddingheight, textSize.height +2*kMessageCell_Paddingheight);
    }
    
    //消息背景视图frame
    CGRect bgImgViewFrame;
    if (!isMyMsg) {     //好友发的
        bgImgViewFrame = CGRectMake(kPaddingLeftWidth + kMessageCell_UserIconWidth, curBottomY + kMessageCell_Paddingheight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kPaddingLeftWidth + kMessageCell_UserIconWidth/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWidth/2)];
        _bgImageView.frame = bgImgViewFrame;
    } else {            //自己发的
        bgImgViewFrame = CGRectMake(kScreen_Width - kPaddingLeftWidth - kMessageCell_UserIconWidth - bgImgViewSize.width, curBottomY + kMessageCell_Paddingheight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kScreen_Width - kPaddingLeftWidth -kMessageCell_UserIconWidth/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWidth/2)];
        _bgImageView.frame = bgImgViewFrame;
    }
    
    //设置背景图片
    bgImg = [UIImage imageNamed:isMyMsg ? @"messageRight_bg_img" : @"messageLeft_bg_img"];
    bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImg.size.height - 19, bgImg.size.width - 31)];
    [_bgImageView setImage:bgImg];
    _bgImageView.backgroundColor = [UIColor blueColor];
    
    //设置头像
    __weak typeof(self) weakSelf = self;
    [_userIconView sd_setImageWithURL:[_curPriMsg.sender.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    
}

#pragma mark - Private Methods
/**
 获取多媒体消息视图的高度(图片、声音、html、猴子表情)
 */
+ (CGFloat)mediaViewHeightWithObj:(PrivateMessage *)curPriMsg {
    CGFloat mediaViewHeight = 0;
    if (curPriMsg.hasMedia) {    //有多媒体消息
        if (curPriMsg.nextImg) {        //是图片
            mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curPriMsg.nextImg].height;
        } else {
            if ([curPriMsg isSingleBigMonkey]) {
                mediaViewHeight += [MessageMediaItemCCell monkeyCcellSize].height;
            } else {
                for (HtmlMediaItem *curItem in curPriMsg.htmlMedia.imageItems) {
                    mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curItem].height + kMessageCell_Paddingheight;
                }
                mediaViewHeight -= kMessageCell_Paddingheight;
            }
        }
    }
    return mediaViewHeight;
}

//时间文本的显示文字
+ (NSString *)displayTimeStrWithCurMsg:(PrivateMessage *)cur preMsg:(PrivateMessage *)pre {
    NSString *displayStr = nil;
    if (!pre || [cur.created_at timeIntervalSinceDate:pre.created_at] > 60) {
        displayStr = [cur.created_at stringDisplay_HHmm];
    }
    return displayStr;
}

@end
