//
//  AudioRecordView.h
//  Coding
//
//  Created by apple on 2019/3/25.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AudioRecordViewTouchState) {
    AudioRecordViewTouchStateInside,
    AudioRecordViewTouchStateOutside
};

@protocol AudioRecorderViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface AudioRecordView : UIControl

@property(nonatomic, assign, readonly)BOOL isRecording;
@property(nonatomic, weak)id<AudioRecorderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END


@protocol AudioRecorderViewDelegate <NSObject>

@optional

- (void)recordViewRecordStarted:(AudioRecordView *)recordView;
- (void)recordViewRecordFinished:(AudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration;
- (void)recordView:(AudioRecordView *)recordView touchStateChanged:(AudioRecordViewTouchState)touchState;
- (void)recordView:(AudioRecordView *)recordView volume:(double)volume;
- (void)recordViewRecord:(AudioRecordView *)recordView err:(NSError *)err;

@end
