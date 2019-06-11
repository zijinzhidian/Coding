//
//  VoiceMedia.h
//  Coding
//
//  Created by apple on 2019/5/17.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoiceMedia : NSObject

@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
