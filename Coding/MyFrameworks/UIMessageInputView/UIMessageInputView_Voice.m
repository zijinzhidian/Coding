//
//  UIMessageInputView_Voice.m
//  Coding
//
//  Created by apple on 2019/3/21.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "UIMessageInputView_Voice.h"
#import "AudioVolumeView.h"
#import "AudioManager.h"
#import "AudioRecordView.h"

typedef NS_ENUM(NSInteger, UIMessageInputView_VoiceState) {
    UIMessageInputView_VoiceStateReady,             //准备状态
    UIMessageInputView_VoiceStateRecording,         //正在说话状态
    UIMessageInputView_VoiceStateCacel              //取消状态
};

@interface UIMessageInputView_Voice ()<AudioRecorderViewDelegate>

@property(nonatomic, strong)UILabel *recordTipsLabel;           //提示文字视图
@property(nonatomic, strong)AudioVolumeView *volumeLeftView;    //左侧音量视图
@property(nonatomic, strong)AudioVolumeView *volumeRightView;   //右侧音量视图
@property(nonatomic, strong)AudioRecordView *recordView;        //录音按钮视图

@property(nonatomic, assign)UIMessageInputView_VoiceState state;
@property(nonatomic, assign)int duration;
@property(nonatomic, strong)NSTimer *timer;

@end

@implementation UIMessageInputView_Voice

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColorNavBG;
        
        //提示文字视图
        _recordTipsLabel = [[UILabel alloc] init];
        _recordTipsLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:_recordTipsLabel];
        
        //左侧音量视图
        _volumeLeftView = [[AudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight) type:AudioVolumeViewTypeLeft];
        _volumeLeftView.hidden = YES;
        [self addSubview:_volumeLeftView];
      
        //右侧音量视图
        _volumeRightView = [[AudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight) type:AudioVolumeViewTypeRight];
        _volumeRightView.hidden = YES;
        [self addSubview:_volumeRightView];
       
        //录音按钮视图
        _recordView = [[AudioRecordView alloc] initWithFrame:CGRectMake((self.frame.size.width - 86) / 2, 62, 86, 86)];
        _recordView.delegate = self;
        [self addSubview:_recordView];
        
        //底部提示文字
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.font = [UIFont systemFontOfSize:12];
        tipLabel.textColor = [UIColor colorWithRGBHex:0x999999];
        tipLabel.text = @"向上滑动，取消发送";
        [tipLabel sizeToFit];
        tipLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25);
        [self addSubview:tipLabel];
        
        self.state = UIMessageInputView_VoiceStateReady;
        _duration = 0;
    }
    return self;
}

- (void)dealloc {
    self.state = UIMessageInputView_VoiceStateReady;
}

#pragma mark - Private Methods
- (NSString *)formattedTime:(int)duration {
    return [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
}

- (void)startTimer {
    _duration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(increaseRecordTime) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)increaseRecordTime {
    _duration++;
    if (self.state == UIMessageInputView_VoiceStateRecording) {
        //更新提示文字
        self.state = UIMessageInputView_VoiceStateRecording;
    }
}

#pragma mark - AudioRecorderViewDelegate
- (void)recordViewRecordStarted:(AudioRecordView *)recordView {
    [_volumeLeftView clearVolume];
    [_volumeRightView clearVolume];
    self.state = UIMessageInputView_VoiceStateRecording;
    [self startTimer];
}

- (void)recordViewRecordFinished:(AudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration {
    [self stopTimer];
    if (self.state == UIMessageInputView_VoiceStateRecording) {
        if (self.recordSuccessfully) {
            self.recordSuccessfully(file, duration);
        }
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    self.state = UIMessageInputView_VoiceStateReady;
    self.duration = 0;
}

- (void)recordView:(AudioRecordView *)recordView touchStateChanged:(AudioRecordViewTouchState)touchState {
    if (self.state != UIMessageInputView_VoiceStateReady) {
        if (touchState == AudioRecordViewTouchStateInside) {
            self.state = UIMessageInputView_VoiceStateRecording;
        } else {
            self.state = UIMessageInputView_VoiceStateCacel;
        }
    }
}

- (void)recordView:(AudioRecordView *)recordView volume:(double)volume {
    [_volumeLeftView addVolume:volume];
    [_volumeRightView addVolume:volume];
}

- (void)recordViewRecord:(AudioRecordView *)recordView err:(NSError *)err {
    [self stopTimer];
    if (self.state == UIMessageInputView_VoiceStateRecording) {
        [NSObject showHudTipStr:err.domain];
    }
    self.state = UIMessageInputView_VoiceStateReady;
    self.duration = 0;
}

#pragma mark - Getters And Setters
- (void)setState:(UIMessageInputView_VoiceState)state {
    _state = state;
    switch (state) {
        case UIMessageInputView_VoiceStateReady:
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"按住说话";
            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
            break;
        case UIMessageInputView_VoiceStateCacel:
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"松开取消";
            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
            break;
        case UIMessageInputView_VoiceStateRecording:
            if (_duration < [AudioManager shared].maxRecordDuration - 5) {
                _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x2FAEEA];
            } else {
                _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0xDE4743];
            }
            _recordTipsLabel.text = [self formattedTime:_duration];
            break;
    }
    
    //设置提示视图位置
    [_recordTipsLabel sizeToFit];
    _recordTipsLabel.center = CGPointMake(self.frame.size.width/2, 20);
    
    //设置音量视图位置
    if (state == UIMessageInputView_VoiceStateRecording) {
        _volumeLeftView.center = CGPointMake(_recordTipsLabel.frame.origin.x - _volumeLeftView.frame.size.width/2 - 12, _recordTipsLabel.center.y);
        _volumeLeftView.hidden = NO;
        _volumeRightView.center = CGPointMake(CGRectGetMaxX(_recordTipsLabel.frame) + _volumeRightView.frame.size.width/2 + 12, _recordTipsLabel.center.y);
        _volumeRightView.hidden = NO;
    }
}

@end
