//
//  PrivateMessage.h
//  Coding
//
//  Created by apple on 2019/5/17.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "VoiceMedia.h"

typedef NS_ENUM(NSInteger, PrivateMessageSendStatus) {
    PrivateMessageStatusSendSucess = 0,
    PrivateMessageStatusSending,
    PrivateMessageStatusSendFail
};


NS_ASSUME_NONNULL_BEGIN

@interface PrivateMessage : NSObject

@property (readwrite, nonatomic, strong) NSString *content, *extra, *file;
@property (readwrite, nonatomic, strong) User *friend, *sender;
@property (readwrite, nonatomic, strong) NSNumber *count, *unreadCount, *id, *read_at, *status, *duration, *played, *type;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (assign, nonatomic) PrivateMessageSendStatus sendStatus;
@property (strong, nonatomic) UIImage *nextImg;
@property (strong, nonatomic) VoiceMedia *voiceMedia;

- (BOOL)hasMedia;
- (BOOL)isSingleBigMonkey;
- (BOOL)isVoice;

+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend;

- (NSString *)toSendPath;
- (NSDictionary *)toSendParams;

- (NSString *)toDeletePath;

@end

NS_ASSUME_NONNULL_END
