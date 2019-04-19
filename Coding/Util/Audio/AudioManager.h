//
//  AudioManager.h
//  Coding
//
//  Created by apple on 2019/3/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AudioManagerDelegate;

@interface AudioManager : NSObject

@property(nonatomic, weak)id<AudioManagerDelegate> delegate;

@property(nonatomic, strong, readonly)AVAudioPlayer *audioPlayer;           //播放器
@property(nonatomic, strong, readonly)AVAudioRecorder *audioRecorder;       //录音器
@property(nonatomic, assign, readonly)BOOL isPlaying;                       //是否正在播放
@property(nonatomic, assign, readonly)BOOL isRecording;                     //是否正在录音
@property(nonatomic, assign)NSTimeInterval minRecordDuration;               //最短录音时间
@property(nonatomic, assign)NSTimeInterval maxRecordDuration;               //最长录音时间

+ (instancetype)shared;


/**
 开始播放

 @param file <#file description#>
 @param validator <#validator description#>
 */
- (void)play:(NSString *)file validator:(id)validator;

/**
 停止播放
 */
- (void)stopPlay;

/**
 开始录音
 */
- (void)record;

/**
 停止录音
 */
- (void)stopRecord;

/**
 全部停止
 */
- (void)stopAll;

@end

NS_ASSUME_NONNULL_END


@protocol AudioManagerDelegate <NSObject>

@optional

//开始录音回调
- (void)didAudioRecordStarted:(AudioManager *)manager;
//正在录音回调(volume:录音音量,取值0.0~1.0)
- (void)didAudioRecording:(AudioManager *)manager volume:(double)volume;
//录音结束回调
- (void)didAudiorecordStoped:(AudioManager *)manager file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully;
//录音错误回调
- (void)didAudioRecord:(AudioManager *)manager err:(NSError *)err;

@end
