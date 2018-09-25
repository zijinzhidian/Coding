//
//  HtmlMedia.h
//  Coding
//
//  Created by apple on 2018/4/26.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "TFHpple.h"

/*TFHpple使用:
 1.添加libxml2.2.tbd
 2.PROJECT-->Build Settings--->All--->Header Search Paths--->添加"/usr/include/libxml2"
 
 */

typedef NS_ENUM(NSInteger, HtmlMediaItemType) {
    HtmlMediaItemType_Image = 0,
    HtmlMediaItemType_Code,
    HtmlMediaItemType_EmotionEmoji,
    HtmlMediaItemType_EmotionMonkey,
    HtmlMediaItemType_ATUser,
    HtmlMediaItemType_AutoLink,
    HtmlMediaItemType_CustomLink,
    HtmlMediaItemType_Math
};

typedef NS_ENUM(NSInteger, MediaShowType) {
    MediaShowTypeNone = 1,
    MediaShowTypeCode = 2,
    MediaShowTypeImage = 3,
    MediaShowTypeMonkey = 5,
    MediaShowTypeImageAndMonkey = 15,
    MediaShowTypeAll = 30
};

@class HtmlMediaItem;

@interface HtmlMedia : NSObject
@property (readwrite, nonatomic, copy) NSString *contentOrigional;
@property (readwrite, nonatomic, strong) NSMutableString *contentDisplay;
@property (readwrite, nonatomic, strong) NSMutableArray *mediaItems;
@property (strong, nonatomic) NSArray *imageItems;
- (void)removeItem:(HtmlMediaItem *)item;
- (BOOL)needToShowDetail;
+ (instancetype)htmlMediaWithString:(NSString *)htmlString showType:(MediaShowType)showType;
- (instancetype)initWithString:(NSString *)htmlString showType:(MediaShowType)showType;


//在curString的末尾添加一个media元素
+ (void)addMediaItem:(HtmlMediaItem *)curItem toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;
+ (void)addLinkStr:(NSString *)linkStr type:(HtmlMediaItemType)type toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;
+ (void)addMediaItemUser:(User *)curUser toString:(NSMutableString *)curString andMediaItems:(NSMutableArray *)itemList;

@end



@interface HtmlMediaItem : NSObject
@property (assign, nonatomic) HtmlMediaItemType type;
@property (assign, nonatomic) MediaShowType showType;
@property (readwrite, nonatomic, strong) NSString *src, *title, *href, *name, *code, *linkStr;
@property (assign, nonatomic) NSRange range;

+ (instancetype)htmlMediaItemWithType:(HtmlMediaItemType)type;
+ (instancetype)htmlMediaItemWithTypeATUser:(User *)curUser mediaRange:(NSRange)curRange;

- (NSString *)displayStr;
- (BOOL)isGif;

@end

