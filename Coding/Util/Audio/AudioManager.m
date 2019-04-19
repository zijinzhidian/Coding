//
//  AudioManager.m
//  Coding
//
//  Created by apple on 2019/3/22.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "AudioManager.h"
#import "AudioAmrUtil.h"

@interface AudioManager ()<AVAudioRecorderDelegate>

@property(nonatomic, copy)NSString *tempFile;       //临时录音文件路径
@property(nonatomic, strong)NSTimer *meterTimer;    //录音音量监测定时器

@end

@implementation AudioManager

#pragma mark - Init
+ (instancetype)shared {
    static AudioManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isPlaying = NO;
        _isRecording = NO;
        _minRecordDuration = 1.0f;
        _maxRecordDuration = 60.0f;
        NSLog(@"%@", NSTemporaryDirectory());
    }
    return self;
}

#pragma mark - Public Methods
- (void)record {
    
    [self stopPlay];
    [self stopRecord];
    
    /*录音参数配置(④~⑦是PCM专属)
     ①AVFormatIDKey:录制音频文件的格式
     ②AVSampleRateKey:采样率,采样频率越高,声音文件质量越好,占用存储空间越大(录音一般用8000)
     ③AVNumberOfChannelsKey:音频通道数,1单声道,2位立体声
     ④AVLinearPCMBitDepthKey:采样位数,声卡处理声音的解析度,这个数值越大，解析度就越高，录制和回放的声音就越真实(一般用16位)
     ⑤AVLinearPCMIsFloatKey:采样信号是整数还是浮点数
     ⑥AVLinearPCMIsNonInterleavedKey:是否允许音频交叉
     ⑦AVLinearPCMIsBigEndianKey:在内存中音频的存储模式是大端还是小端
     */
    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                               AVSampleRateKey: @8000,
                               AVNumberOfChannelsKey: @2,
                               AVLinearPCMBitDepthKey: @16,
                               AVLinearPCMIsFloatKey: @NO,
                               AVLinearPCMIsNonInterleaved: @NO,
                               AVLinearPCMIsBigEndianKey: @NO
                               };
    
    //录音文件路径
    _tempFile = [[self class] tmpFile];
    //录音错误
    NSError *error;
    //初始化录音器对象
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_tempFile] settings:settings error:&error];
    //初始化失败
    if (error) {
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecord:err:)]) {
            [_delegate didAudioRecord:self err:error];
        }
        [self stopRecord];
        return;
    }
    
    //设置该应用同时支持播放和录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //录音需要阻断后台音乐的播放
    [[AVAudioSession sharedInstance] setActive:YES error: nil];

    _isRecording = YES;
    __weak typeof(self) weakSelf = self;
    //请求麦克风权限
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if (weakSelf.isRecording) {
                //设置代理
                weakSelf.audioRecorder.delegate = weakSelf;
                //开启音量检测
                weakSelf.audioRecorder.meteringEnabled = YES;
                //开始录音
                [weakSelf.audioRecorder record];
                //开始监控录音音量
                [weakSelf startUpdateMeter];
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didAudioRecordStarted:)]) {
                    [weakSelf.delegate didAudioRecordStarted:weakSelf];
                }
            }
        } else {
            self->_isRecording = NO;
            [UIAlertController showAlertViewWithTitle:@"没有权限"];
        }
    }];
}

- (void)stopRecord {
    [self stopRecord:YES];
}

- (void)stopRecord:(BOOL)successfully {
    [self stopUpdateMeter];
    NSTimeInterval duration = 0;
    if (_audioRecorder) {
        duration = _audioRecorder.currentTime;
        [_audioRecorder stop];
        _audioRecorder = nil;
    }
    if (_isRecording) {
        _isRecording = NO;
        if (duration < _minRecordDuration) {
            if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecord:err:)]) {
                [_delegate didAudioRecord:self err:[NSError errorWithDomain:@"录音时间过短" code:200 userInfo:nil]];
            }
        } else {
            NSString *recordFile = [AudioAmrUtil encodeWaveToAmr:_tempFile];
            if (_delegate && [_delegate respondsToSelector:@selector(didAudiorecordStoped:file:duration:successfully:)]) {
                [_delegate didAudiorecordStoped:self file:recordFile duration:duration successfully:successfully];
            }
        }
        //移除临时文件
        [[NSFileManager defaultManager] removeItemAtPath:_tempFile error:nil];
        _tempFile = nil;
    }
}

- (void)play:(NSString *)file validator:(id)validator {
    
}

- (void)stopPlay {
    
}

- (void)stopPlay: (BOOL)successfully {
    
}

- (void)stopAll {
    if (_isPlaying) {
        [self stopRecord];
    }
    if (_isRecording) {
        [self stopPlay];
    }
}

#pragma mark - Private Methods
+ (NSString *)tmpFile {
    //录音文件夹路径
    NSString *dir = [NSTemporaryDirectory() stringByAppendingString:@"AudioRecord"];
    //创建录音文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    //录音文件路径
    NSString *file = [[dir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"caf"];
    return file;
}

//开始监测录音音量
- (void)startUpdateMeter {
    self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeter) userInfo:nil repeats:YES];
}

//关闭监测录音音量
- (void)stopUpdateMeter {
    if (self.meterTimer) {
        [self.meterTimer invalidate];
        self.meterTimer = nil;
    }
}

//更新录音音量
- (void)updateMeter {
    [_audioRecorder updateMeters];    //刷新音量
    
    double volume;          //0.0~1.0
    float minDecibels = -80.0f;      //最小分贝
    float decibels = [_audioRecorder averagePowerForChannel:0];    //获取通道的平均分贝
    
    if (decibels < minDecibels) {
        volume = 0.0f;
    } else if (decibels >= 0.0f) {
        volume = 1.0f;
    } else {
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        
        volume = pow(adjAmp, 1.0f / root);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecording:volume:)]) {
        [_delegate didAudioRecording:self volume:volume];
    }
    
    if (_audioRecorder.currentTime >= _maxRecordDuration + 0.1f) {
        [self stopRecord];
    }
}

#pragma mark - AVAudioRecorderDelegate
//录音完成回调
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    NSLog(@"录音完成：%d", flag);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [self stopRecord:NO];
    NSLog(@"录音错误：%@",error);
}



@end
