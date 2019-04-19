//
//  AudioRecordView.m
//  Coding
//
//  Created by apple on 2019/3/25.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "AudioRecordView.h"
#import "AudioManager.h"

@interface AudioRecordView ()<AudioManagerDelegate>

@property(nonatomic, strong)UIImageView *imageView;

@property(nonatomic, strong)UIView *spreadView;
@property(nonatomic, strong)UIView *recordBgView;
@property(nonatomic, strong)UIView *flashView;

@property(nonatomic, assign)AudioRecordViewTouchState touchState;

@end

@implementation AudioRecordView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _isRecording = NO;
        
        _spreadView = [[UIView alloc] initWithFrame:CGRectMake(-8, -8, self.frame.size.width + 16, self.frame.size.height + 16)];
        _spreadView.backgroundColor = [UIColor colorWithRGBHex:0xC6ECFD];
        _spreadView.layer.cornerRadius = _spreadView.frame.size.height / 2;
        _spreadView.alpha = 0;
        [self addSubview:_spreadView];
        
        _recordBgView = [[UIView alloc] initWithFrame:CGRectMake(-8, -8, self.frame.size.width + 16, self.frame.size.height + 16)];
        _recordBgView.backgroundColor = [UIColor colorWithRGBHex:0x7ACFFB];
        _recordBgView.layer.cornerRadius = _recordBgView.frame.size.height / 2;
        _recordBgView.hidden = YES;
        [self addSubview:_recordBgView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.image = [UIImage imageNamed:@"keyboard_voice_record"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        _flashView = [[UIView alloc] initWithFrame:self.bounds];
        _flashView.backgroundColor = [UIColor whiteColor];
        _flashView.layer.cornerRadius = _flashView.frame.size.height / 2;
        _flashView.alpha = 0;
        [self addSubview:_flashView];
        
        [self addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark - UIControl Events
- (void)onTouchDown {
    [self record];
}

- (void)onTouchUpInside {
    [self stop];
}

- (void)onTouchUpOutside {
    [self stop];
}

#pragma mark - Touch Events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _touchState = AudioRecordViewTouchStateInside;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    BOOL touchInside = [self pointInside:[touch locationInView:self] withEvent:nil];
    BOOL touchStateChanged = NO;
    if (_touchState == AudioRecordViewTouchStateInside && !touchInside) {
        _touchState = AudioRecordViewTouchStateOutside;
        touchStateChanged = YES;
    } else if (_touchState == AudioRecordViewTouchStateOutside && touchInside) {
        _touchState = AudioRecordViewTouchStateInside;
        touchStateChanged = YES;
    }
    
    if (touchStateChanged) {
        if (_delegate && [_delegate respondsToSelector:@selector(recordView:touchStateChanged:)]) {
            [_delegate recordView:self touchStateChanged:_touchState];
        }
    }
}

#pragma mark - Private Methods
- (void)record {
    [self stop];
    
    [[AudioManager shared] stopPlay];
    [[AudioManager shared] record];
    [AudioManager shared].delegate = self;
}

- (void)stop {
    _isRecording = NO;
    [self stopAnimation];
    [[AudioManager shared] stopRecord];
}


#pragma mark - Amimation
- (void)startAnimation {
    _recordBgView.hidden = NO;
    _spreadView.alpha = 1.0f;
    _spreadView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    _flashView.alpha = 0.4f;
    
    [UIView beginAnimations:@"RecordAnimation" context:nil];
    [UIView setAnimationDuration:1.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    
    _spreadView.alpha = 0;
    _spreadView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    _flashView.alpha = 0;
    
    [UIView commitAnimations];
}

- (void)stopAnimation {
    [_flashView.layer removeAllAnimations];
    [_spreadView.layer removeAllAnimations];
    
    _recordBgView.hidden = YES;
    _spreadView.alpha = 0;
    _flashView.alpha = 0;
}


#pragma mark - AudioManagerDelegate
- (void)didAudioRecordStarted:(AudioManager *)manager {
    _isRecording = YES;
    [self startAnimation];
    
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordStarted:)]) {
        [_delegate recordViewRecordStarted:self];
    }
}

- (void)didAudioRecording:(AudioManager *)manager volume:(double)volume {
    if (_delegate && [_delegate respondsToSelector:@selector(recordView:volume:)]) {
        [_delegate recordView:self volume:volume];
    }
}

- (void)didAudiorecordStoped:(AudioManager *)manager file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully {
    _isRecording = NO;
    [self stop];
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordFinished:file:duration:)]) {
        [_delegate recordViewRecordFinished:self file:file duration:duration];
    }
}

- (void)didAudioRecord:(AudioManager *)manager err:(NSError *)err {
    _isRecording = NO;
    [self stop];
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecord:err:)]) {
        [_delegate recordViewRecord:self err:err];
    }
}

@end
