//
//  UIMessageInputView.m
//  Coding
//
//  Created by apple on 2019/3/20.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#define kKeyboardView_Height 216.0                  //键盘高度
#define kMessageInputView_Height 50.0
#define kMessageInputView_PaddingHeight 7.0
#define kMessageInputView_ButtonWidth 35.0          //单个按钮宽度
#define kMessageInputView_ButtonDistance 7.0        //按钮两侧间距


#import "UIMessageInputView.h"
#import "UIPlaceHolderTextView.h"
#import "UIMessageInputView_Add.h"
#import "UIMessageInputView_Voice.h"
#import "UIMessageInputView_Media.h"

#import "QBImagePickerController.h"
#import "Helper.h"

#import "Coding_FileManager.h"

static NSMutableDictionary *_inputStrDict, *_inputMediaDict;

@interface UIMessageInputView ()<EmojiKeyboardDataSource, EmojiKeyboardDelegate, UITextViewDelegate, QBImagePickerControllerDelegate>

@property(nonatomic, strong)UIScrollView *contentView;                  //输入框内容视图
@property(nonatomic, strong)UIPlaceHolderTextView *inputTextView;       //输入框视图
@property(nonatomic, strong)UIButton *arrowKeyboardButton;              //处于说话界面时的箭头按钮

@property(nonatomic, strong)NSMutableArray *mediaList;
@property(nonatomic, strong)NSMutableArray *uploadMediaList;

@property(nonatomic, strong)EmojiKeyboardView *emojiKeyboardView;       //表情按钮视图
@property(nonatomic, strong)UIMessageInputView_Add *addKeyboardView;    //添加按钮视图
@property(nonatomic, strong)UIMessageInputView_Voice *voiceKeyboardView;//说话按钮视图

@property(nonatomic, strong)UIButton *emotionButton;                    //表情按钮
@property(nonatomic, strong)UIButton *addButton;                        //添加按钮
@property(nonatomic, strong)UIButton *photoButton;                      //照相按钮
@property(nonatomic, strong)UIButton *voiceButton;                      //说话按钮

@property(nonatomic, assign)UIMessageInputViewState inputState;         //输入键盘状态

@property(nonatomic, strong)MBProgressHUD *progressHUD;                 //上传进度HUD
@property(nonatomic, strong)NSString *uploadingPhotoName;              //正在上传的图片名称

@end

@implementation UIMessageInputView

#pragma mark - 初始化
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type {
    return [self messageInputViewWithType:type placeHolder:@""];
}

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder {
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView customUIWithType:type];
    if (![placeHolder isEqualToString:@""]) {
        messageInputView.placeHolder = placeHolder;
    } else {
        messageInputView.placeHolder = @"撰写评论";
    }
    return messageInputView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorNavBG;
        [self addLineUp:YES andDown:NO andColor:kColorCCC];
        self.inputState = UIMessageInputViewStateSystem;
        self.isAlwaysShow = NO;
    }
    return self;
}

#pragma mark - Public Methods
- (void)prepareToShow {
    if ([self superview] == kKeyWindow) {
        return;
    }
    [self p_setY:kScreen_Height];
    [kKeyWindow addSubview:self];
    [kKeyWindow addSubview:_emojiKeyboardView];
    [kKeyWindow addSubview:_addKeyboardView];
    [kKeyWindow addSubview:_voiceKeyboardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (self.isAlwaysShow && ![self isCustomFirstResponder]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self p_setY:kScreen_Height - CGRectGetHeight(self.frame)];
        }];
    }
}

- (void)prepareToDismiss {
    if ([self superview] == nil) {
        return;
    }
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self p_setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [self.emojiKeyboardView removeFromSuperview];
        [self.addKeyboardView removeFromSuperview];
        [self.voiceKeyboardView removeFromSuperview];
        [self removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//当前是否为第一响应者(当inputState为UIMessageInputViewStateSystem时,消息键盘收起)
- (BOOL)isCustomFirstResponder {
    return ([self.inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice);
}

#pragma mark - Private Methods
//自定义UI
- (void)customUIWithType:(UIMessageInputViewContentType)type {
    
    _contentType = type;

    NSInteger toolBtnNum;       //输入框右侧按钮数量
    BOOL hasEmotionBtn;         //是否需要表情按钮
    BOOL hasAddBtn;             //是否需要添加按钮
    BOOL hasPhotoBtn;           //是否需要照相按钮
    BOOL hasVoiceBtn;           //是否需要说话按钮
    BOOL showBigEmotion;        //是否显示大表情
    
    switch (_contentType) {
        case UIMessageInputViewContentTypeTweet: {
            toolBtnNum = 1;
            hasEmotionBtn = YES;
            hasAddBtn = NO;
            hasPhotoBtn = NO;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
        }
            break;
            
        case UIMessageInputViewContentTypePriMsg: {
            toolBtnNum = 2;
            hasEmotionBtn = YES;
            hasAddBtn = YES;
            hasPhotoBtn = NO;
            showBigEmotion = YES;
            hasVoiceBtn = YES;
        }
            break;
        case UIMessageInputViewContentTypeTask:
        case UIMessageInputViewContentTypeTopic: {
            toolBtnNum = 1;
            hasEmotionBtn = NO;
            hasAddBtn = NO;
            hasPhotoBtn = YES;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
        }
            break;
    }
    
    CGFloat contentViewHeight = kMessageInputView_Height - 2 * kMessageInputView_PaddingHeight;
    CGFloat contentViewPaddingLeft = (hasVoiceBtn ? kMessageInputView_ButtonWidth + 2 * kMessageInputView_ButtonDistance : kPaddingLeftWidth);
    CGFloat contentViewPaddingRight = (2 * kMessageInputView_ButtonDistance + toolBtnNum * kMessageInputView_ButtonWidth);
    
    __weak typeof(self) weakSelf = self;
    //输入框内容视图
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.cornerRadius = contentViewHeight / 2;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMessageInputView_PaddingHeight, contentViewPaddingLeft, kMessageInputView_PaddingHeight, contentViewPaddingRight));
        }];
    }
    
    //输入框视图
    if (!_inputTextView) {
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - contentViewPaddingLeft - contentViewPaddingRight, contentViewHeight)];
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO;
        _inputTextView.delegate = self;
        [_contentView addSubview:_inputTextView];
        
        //输入框缩进
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;
    }
    
    //表情按钮
    if (hasEmotionBtn && !_emotionButton) {
        _emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emotionButton.frame = CGRectMake(kScreen_Width - toolBtnNum * kMessageInputView_ButtonWidth - kMessageInputView_ButtonDistance , (kMessageInputView_Height - kMessageInputView_ButtonWidth) / 2, kMessageInputView_ButtonWidth, kMessageInputView_ButtonWidth);
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emotionButton];
    }
    _emotionButton.hidden = !hasEmotionBtn;
    
    //添加按钮
    if (hasAddBtn && !_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(kScreen_Width - (toolBtnNum - 1) * kMessageInputView_ButtonWidth - kMessageInputView_ButtonDistance, (kMessageInputView_Height - kMessageInputView_ButtonWidth) / 2, kMessageInputView_ButtonWidth, kMessageInputView_ButtonWidth);
        [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
    }
    _addButton.hidden = !hasAddBtn;
    
    //照相按钮
    if (hasPhotoBtn && !_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectMake(kScreen_Width - toolBtnNum * kMessageInputView_ButtonWidth - kMessageInputView_ButtonDistance, (kMessageInputView_Height - kMessageInputView_ButtonWidth) / 2, kMessageInputView_ButtonWidth, kMessageInputView_ButtonWidth);
        [_photoButton setImage:[UIImage imageNamed:@"keyboard_photo"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(phoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_photoButton];
    }
    _photoButton.hidden = !hasPhotoBtn;
    
    //说话按钮
    if (hasVoiceBtn && !_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.frame = CGRectMake(kMessageInputView_ButtonDistance, (kMessageInputView_Height - kMessageInputView_ButtonWidth) / 2, kMessageInputView_ButtonWidth, kMessageInputView_ButtonWidth);
        [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceButton];
    }
    _voiceButton.hidden = !hasVoiceBtn;
    
    //箭头按钮
    if (hasVoiceBtn && !_arrowKeyboardButton) {
        _arrowKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowKeyboardButton.frame = CGRectMake(0, 0, kMessageInputView_ButtonWidth, kMessageInputView_ButtonWidth);
        [_arrowKeyboardButton setImage:[UIImage imageNamed:@"keyboard_arrow_down"] forState:UIControlStateNormal];
        [_arrowKeyboardButton addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_arrowKeyboardButton];
    }
    _arrowKeyboardButton.hidden = YES;
    
    //表情按钮视图
    if (hasEmotionBtn && !_emojiKeyboardView) {
        _emojiKeyboardView = [[EmojiKeyboardView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height) dataSource:self showBigEmotion:showBigEmotion];
        _emojiKeyboardView.delegate = self;
        [_emojiKeyboardView setY:kScreen_Height];
    }
    
    //添加按钮视图
    if (hasAddBtn && !_addKeyboardView) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _addKeyboardView.addIndexBlock = ^(NSInteger index) {
            if ([weakSelf.delegate respondsToSelector:@selector(messageInputView:addIndexClick:)]) {
                [weakSelf.delegate messageInputView:weakSelf addIndexClick:index];
            }
        };
    }
    
    //说话按钮视图
    if (hasVoiceBtn && !_voiceKeyboardView) {
        _voiceKeyboardView = [[UIMessageInputView_Voice alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _voiceKeyboardView.recordSuccessfully = ^(NSString * _Nonnull file, NSTimeInterval duration) {
            if ([weakSelf.delegate respondsToSelector:@selector(messageInputView:sendVoice:duration:)]) {
                [weakSelf.delegate messageInputView:weakSelf sendVoice:file duration:duration];
            }
        };
    }
}

//设置Y坐标
- (void)p_setY:(CGFloat)y {
    //若消息视图在屏幕内,则需要适配安全区域
    if (ABS(kScreen_Height - CGRectGetHeight(self.frame)- y) < 1.0) {
        y -= kSafeArea_Bottom;
    }
    [self setY:y];
}

//收起消息键盘
- (BOOL)isAndResignFirstResponder {
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [self.emojiKeyboardView setY:kScreen_Height];
            [self.addKeyboardView setY:kScreen_Height];
            [self.voiceKeyboardView setY:kScreen_Height];
            if (self.isAlwaysShow) {
                [self p_setY:kScreen_Height - CGRectGetHeight(self.frame)];
            } else {
                [self p_setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        return YES;
    } else {
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
            return YES;
        } else {
            return NO;
        }
    }
}

//发送消息
- (void)sentTextStr {
    //情况缓存的输入数据
    [self deleteInputData];
    
    NSMutableString *sendStr = [NSMutableString stringWithString:self.inputTextView.text];
    if (sendStr && ![sendStr isEmpty] && self.delegate && [self.delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
    }
}

#pragma mark - remember input
- (NSMutableDictionary *)shareInputStrDict {
    if (!_inputStrDict) {
        _inputStrDict = [[NSMutableDictionary alloc] init];
    }
    return _inputStrDict;
}

- (NSMutableDictionary *)shareInputMediaDict {
    if (!_inputMediaDict) {
        _inputMediaDict = [[NSMutableDictionary alloc] init];
    }
    return _inputMediaDict;
}

//保存到字典的key
- (NSString *)inputKey{
    NSString *inputKey = nil;
    if (_contentType == UIMessageInputViewContentTypePriMsg) {
        inputKey = [NSString stringWithFormat:@"privateMessage_%@", self.toUser.global_key];
    }else{
        if (_commentOfId) {
            switch (_contentType) {
                case UIMessageInputViewContentTypeTweet:
                    inputKey = [NSString stringWithFormat:@"tweet_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                case UIMessageInputViewContentTypeTopic:
                    inputKey = [NSString stringWithFormat:@"topic_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                case UIMessageInputViewContentTypeTask:
                    inputKey = [NSString stringWithFormat:@"task_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                default:
                    break;
            }
        }
    }
    return inputKey;
}

//获取保存的输入字符串
- (NSString *)inputStr {
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputStrDict] objectForKey:inputKey];
    }
    return nil;
}

//获取保存的输入多媒体
- (NSMutableArray *)inputMedia {
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputMediaDict] objectForKey:inputKey];
    }
    return nil;
}

//保存输入字符串
- (void)saveInputStr {
    NSString *inputStr = self.inputTextView.text;
    NSString *inputKey = [self inputKey];
    if (inputKey && inputStr.length > 0) {
        [[self shareInputStrDict] setObject:inputStr forKey:inputKey];
    } else {
        [[self shareInputStrDict] removeObjectForKey:inputKey];
    }
}

//保存输入的多媒体
- (void)saveInputMedia {
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        if (self.mediaList.count > 0) {
            [[self shareInputMediaDict] setObject:self.mediaList forKey:inputKey];
        } else {
            [[self shareInputMediaDict] removeObjectForKey:inputKey];
        }
    }
}

//删除保存的数据,包括字符串和多媒体
- (void)deleteInputData {
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        [[self shareInputStrDict] removeObjectForKey:inputKey];
        [[self shareInputMediaDict] removeObjectForKey:inputKey];
    }
}

#pragma mark - Button Methods
- (void)emotionButtonClicked:(UIButton *)sender {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateEmotion) {
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateEmotion;
        [self.inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height - kSafeArea_Bottom;
    }
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self.emojiKeyboardView setY:endY];
        [self.addKeyboardView setY:kScreen_Height];
        [self.voiceKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 1.0) {
            [self p_setY:endY - CGRectGetHeight(self.frame)];
        }
    } completion:NULL];
}

- (void)addButtonClicked:(UIButton *)sender {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateAdd) {
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateAdd;
        [self.inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height - kSafeArea_Bottom;
    }
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self.addKeyboardView setY:endY];
        [self.emojiKeyboardView setY:kScreen_Height];
        [self.voiceKeyboardView setY:kScreen_Height];
        //当变为系统键盘时不变
        if (ABS(kScreen_Height - endY) > 1.0) {
            [self p_setY:endY - CGRectGetHeight(self.frame)];
        }
    } completion:NULL];
}

- (void)voiceButtonClicked:(UIButton *)sender {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateVoice;
        [self.inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height - kSafeArea_Bottom;
    }
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self.voiceKeyboardView setY:endY];
        [self.emojiKeyboardView setY:kScreen_Height];
        [self.addKeyboardView setY:kScreen_Height];
        //当变为系统键盘时不变
        if (ABS(kScreen_Height - endY) > 1.0) {
            [self p_setY:endY - CGRectGetHeight(self.frame)];
        }
    } completion:NULL];
}

- (void)phoneButtonClicked:(UIButton *)sender {
    
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    
    [self isAndResignFirstResponder];
    
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    [[BaseViewController presentingVC] presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)arrowButtonClicked:(UIButton *)sender {
    [self isAndResignFirstResponder];
}

#pragma mark - Keyboard Notifation Handler
- (void)keyboardChange:(NSNotification *)notication {
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary *userInfo = [notication userInfo];
        //键盘结束动画后的Frame
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //键盘结束动画后的Y坐标
        CGFloat keyboardY = keyboardEndFrame.origin.y;
        /*
         ①键盘即将显示(keyboardY + 1 < kScreen_Height):将消息视图显示在键盘上面
         ②键盘即将隐藏(keyboardY + 1 > kScreen_Height):需要判断消息视图是否一直显示在底部
         */
        CGFloat selfEndY = keyboardY + 1 > kScreen_Height ? (self.isAlwaysShow ? kScreen_Height - CGRectGetHeight(self.frame) : kScreen_Height) : keyboardY - CGRectGetHeight(self.frame);
        
        if (notication.name == UIKeyboardWillChangeFrameNotification) {
            //键盘动画时间
            NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            //键盘动画曲线
            UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
            //执行动画
            [UIView animateWithDuration:animationDuration delay:0 options:[UIView animationOptionsForCurve:animationCurve] animations:^{
                [self p_setY:selfEndY];
            } completion:nil];
        }
    }
}


#pragma mark - EmojiKeyboardDataSource
- (UIImage *)emojiKeyboardView:(EmojiKeyboardView *)emogiKeyboardView imageForSelectedCategory:(EmojiKeyboardViewCategoryImage)category {
    UIImage *img = [UIImage imageNamed:(category == EmojiKeyboardViewCategoryImageEmoji ? @"keyboard_emotion_emoji":
                                        category == EmojiKeyboardViewCategoryImageMonkey ? @"keyboard_emotion_monkey":
                                        category == EmojiKeyboardViewCategoryImageMonkey_Gif ? @"keyboard_emotion_monkey_gif":
                                        @"keyboard_emotion_emoji_code")] ?: [[UIImage alloc] init];
    return img;
}

- (UIImage *)emojiKeyboardView:(EmojiKeyboardView *)emogiKeyboardView imageForNonSelectedCategory:(EmojiKeyboardViewCategoryImage)category {
    return [self emojiKeyboardView:emogiKeyboardView imageForSelectedCategory:category];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(EmojiKeyboardView *)emojiKeyboardView {
    return [UIImage imageNamed:@"keyboard_emotion_delete"];
}

#pragma mark - EmojiKeyboardDelegate
- (void)emojiKeyboardView:(EmojiKeyboardView *)emojiKeyboardView didUseEmoji:(NSString *)emoji {
    NSString *emotion_monkey = [emoji emotionSpecailName];
    if (emotion_monkey) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputView:sendBigEmotion:)]) {
            [self.delegate messageInputView:self sendBigEmotion:emotion_monkey];
        }
    } else {
        [self.inputTextView insertText:emoji];
    }
}

- (void)emojiKeyboardViewDidPressBackSpace:(EmojiKeyboardView *)emojiKeyboardView {
    [self.inputTextView deleteBackward];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    _uploadMediaList = [[NSMutableArray alloc] initWithCapacity:assets.count];
    for (PHAsset *asset in assets) {
        [_uploadMediaList addObject:[UIMessageInputView_Media mediaWithAsset:asset urlStr:nil]];
    }
    [self doUploadMediaList];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [[BaseViewController presentingVC] dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - uploadMedia
- (void)doUploadMediaList {
    __block UIMessageInputView_Media *media = nil;
    __block NSInteger index = 0;
    [_uploadMediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
        media = obj;
        index = idx;
        *stop = YES;
    }];
    if (media && media.curAsset) {
        [self doUploadMedia:media withIndex:index];
    } else {
        //隐藏progressHUD
        [self hudTipWillShow:nil];
        [[BaseViewController presentingVC] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doUploadMedia:(UIMessageInputView_Media *)media withIndex:(NSInteger)index {
    NSString *originalFileName = media.curAsset.fileName;
    NSString *fileName = [NSString stringWithFormat:@"%@|||%@|||%@", self.curProject.id.stringValue, @"0", originalFileName];
    NSLog(@"----%@",fileName);
    //写入磁盘
//    if ([Coding_FileManager writeUploadDataWithFileName:fileName andAsset:media.curAsset]) {
//        [self hudTipWillShow:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index + 1]];
//        media.state = UIMessageInputView_MediaStateUploading;
//        self.uploadingPhotoName = originalFileName;
//        Coding_UploadTask *uploadTask = [[Coding_FileManager sharedManager] ];
//    } else {
//
//    }
}

- (void)hudTipWillShow:(NSString *)tipStr {
    if (tipStr.length > 0) {
        //收起键盘
        [self resignFirstResponder];
        
        if (!_progressHUD) {
            _progressHUD = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
            _progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
            _progressHUD.removeFromSuperViewOnHide = YES;
        } else {
            [kKeyWindow addSubview:_progressHUD];
            [_progressHUD showAnimated:NO];
        }
        _progressHUD.progress = 0;
        _progressHUD.label.text = tipStr;
    } else {
        [_progressHUD hideAnimated:NO];
    }
}

#pragma mark - Getters And Setters
- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    if (_inputTextView && ![_inputTextView.placeholder isEqualToString:placeHolder]) {
        _inputTextView.placeholder = placeHolder;
    }
}

- (void)setInputState:(UIMessageInputViewState)inputState {
    if (_inputState != inputState) {
        _inputState = inputState;
        switch (_inputState) {
            case UIMessageInputViewStateSystem:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateVoice:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
            }
                break;
        }
        _contentView.hidden = _inputState == UIMessageInputViewStateVoice;
        _arrowKeyboardButton.hidden = !_contentView.hidden;
        
        _arrowKeyboardButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
}

@end
