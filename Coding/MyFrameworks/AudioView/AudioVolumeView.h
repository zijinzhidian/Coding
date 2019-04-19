//
//  AudioVolumeView.h
//  Coding
//
//  Created by apple on 2019/3/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#define kAudioVolumeViewVolumeWidth 2.0f                //音量宽度
#define kAudioVolumeViewVolumeMinHeight 3.0f            //音量最小高度
#define kAudioVolumeViewVolumeMaxHeight 16.0f           //音量最大高度
#define kAudioVolumeViewVolumePadding 2.0f              //每格音量间隔
#define kAudioVolumeViewVolumeNumber 10                 //音量格数

//音量视图宽度
#define kAudioVolumeViewWidth (kAudioVolumeViewVolumeWidth * kAudioVolumeViewVolumeNumber + kAudioVolumeViewVolumePadding * (kAudioVolumeViewVolumeNumber - 1))
//音量视图高度
#define kAudioVolumeViewHeight kAudioVolumeViewVolumeMaxHeight

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AudioVolumeViewType) {
    AudioVolumeViewTypeLeft,
    AudioVolumeViewTypeRight,
};

NS_ASSUME_NONNULL_BEGIN

@interface AudioVolumeView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(AudioVolumeViewType)type;

- (void)addVolume:(double)volume;
- (void)clearVolume;

@end

NS_ASSUME_NONNULL_END
