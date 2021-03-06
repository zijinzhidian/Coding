//
//  NSString+Common.m
//  Coding
//
//  Created by apple on 2018/4/24.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import <RegexKitLite_NoWarning/RegexKitLite.h>

@implementation NSString (Common)

#pragma mark - 字符类型判断
//判断是否为整形
- (BOOL)isPureInt {
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点型
- (BOOL)isPureFloat {
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

//判断是否为手机号
- (BOOL)isPhoneNo {
    NSString *phoneRegex = @"[0-9]{1,15}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

//判断是否为邮箱
- (BOOL)isEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

//判断是否为用户名
- (BOOL)isGK{
    NSString *gkRegex = @"[A-Z0-9a-z-_]{3,32}";
    NSPredicate *gkTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", gkRegex];
    return [gkTest evaluateWithObject:self];
}

//判断是否为文件名
- (BOOL)isFileName {
    NSString *fileNameRegex = @"[a-zA-Z0-9\\u4e00-\\u9fa5\\./_-]+$";
    NSPredicate *fileNameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", fileNameRegex];
    return [fileNameTest evaluateWithObject:self];
}

#pragma mark - 加密
//MD5加密
- (NSString *)md5Str {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//SHA1加密
- (NSString *)sha1Str {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


#pragma mark - 去除特殊字符
//获取左边特殊字符范围
- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}

//获取右边特殊字符范围
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet{
    NSUInteger location = 0;
    NSUInteger length = [self length];
    unichar charBuffer[length];
    [self getCharacters:charBuffer];
    for (length = [self length]; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    return NSMakeRange(location, length - location);
}

//去掉左边特殊字符
- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingLeftCharactersInSet:characterSet]];
}

//去掉右边特殊字符
- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet {
    return [self substringWithRange:[self rangeByTrimmingRightCharactersInSet:characterSet]];
}

//去掉前后空格
- (NSString *)trimWhitespace {
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

//判断去掉前后空格后是否为空字符串
- (BOOL)isEmpty {
    return [[self trimWhitespace] isEqualToString:@""];
}

#pragma mark - 获取字符串的尺寸
//宽高
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    resultSize = [self boundingRectWithSize:CGSizeMake(floor(size.width), floor(size.height)) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style} context:nil].size;
    return CGSizeMake(resultSize.width + 1, resultSize.height + 1);
}

//高
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self getSizeWithFont:font constrainedToSize:size].height;
}

//宽
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self getSizeWithFont:font constrainedToSize:size].width;
}

#pragma mark - 根据图片路径获取图片网络地址
//获取制定宽度的图片url,不裁剪
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width{
    return [self urlImageWithCodePathResize:width crop:NO];
}

//获取指定宽度的图片url,指定是否裁剪
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop {
    if (!self || self.length <= 0) {
        return nil;
    }
    
    NSString *urlStr;
    BOOL canCrop = NO;
    if (![self hasPrefix:@"http"]) {            //不以http开头
        /*
         1.stringByMatching:capture:-->匹配正则表达式
         2.capture:表示需要返回的匹配字符串,0表示返回匹配成功后全部字符串,1表示返回匹配成功的第一处...
         3.所有正则表达式的\在写出OC正则字符串时要写出\\,例如[+\-]?[0-9]+需要写成[+\\-]?[0-9]+
         */
        /*([a-zA-Z0-9\\-._]+)$   表示匹配的字符串只能是数字、字母、-、.和_  例如a_b-24.png
         当capture为0时,imageName为/static/fruit_avatar/a_b-24.png
         当capture为1时,imageName为a_b-24.png
         当capture为2时,报错
         */
        NSString *imageName = [self stringByMatching:@"/static/fruit_avatar/([a-zA-Z0-9\\-._]+)$" capture:1];
        if (!imageName) {
            imageName = [self stringByMatching:@"/static/project_icon/([a-zA-Z0-9\\-._]+)$" capture:1];
        }
        if (imageName && imageName.length > 0) {
            //%.0f表示取浮点数的整数部分
            urlStr = [NSString stringWithFormat:@"http://coding-net-avatar.qiniudn.com/%@?imageMogr2/auto-orient/thumbnail/!%.0fx%.0fr", imageName, width, width];
            canCrop = YES;
        } else {
            urlStr = [NSString stringWithFormat:@"%@%@", [NSObject baseURLStr], [self hasPrefix:@"/"] ? [self substringFromIndex:1] : self];
        }
    } else {        //以http开头
        urlStr = self;
        if ([urlStr rangeOfString:@"qbox.me"].location != NSNotFound) {     //包含qbox.me
            if ([urlStr rangeOfString:@".gif"].location != NSNotFound) {
                if ([urlStr rangeOfString:@"?"].location != NSNotFound) {
                    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/thumbnail/!%.0fx%.0fr/format/png", width, width]];
                }else{
                    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"?imageMogr2/auto-orient/thumbnail/!%.0fx%.0fr/format/png", width, width]];
                }
            } else {
                if ([urlStr rangeOfString:@"?"].location != NSNotFound) {
                    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/thumbnail/!%.0fx%.0fr", width, width]];
                }else{
                    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"?imageMogr2/auto-orient/thumbnail/!%.0fx%.0fr", width, width]];
                }
            }
            canCrop = YES;
        } else if ([urlStr rangeOfString:@"www.gravatar.com"].location != NSNotFound) { //包含www.gravatar.com
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"s=[0-9]*" withString:[NSString stringWithFormat:@"s=%.0f",width] options:NSRegularExpressionSearch range:NSMakeRange(0, urlStr.length)];
        } else if ([urlStr hasSuffix:@"/imagePreview"]) {       //以/imagePreview结尾
            urlStr = [urlStr stringByAppendingFormat:@"?width=%.0f", width];
        }
    }
    if (needCrop && canCrop) {
        urlStr = [urlStr stringByAppendingFormat:@"/gravity/Center/crop/%.0fx%.0f", width, width];
    }
    return [NSURL URLWithString:urlStr];
}

//获取自适应视图宽度的图片url,不裁剪
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view {
    return [self urlImageWithCodePathResize:[UIScreen mainScreen].scale * view.frame.size.width];
}

#pragma mark - 表情名称
+ (NSDictionary *)emotion_specail_dict {
    static NSDictionary *_emotion_specail_dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emotion_specail_dict = @{
                                  //猴子大表情
                                  @"coding_emoji_01": @" :哈哈: ",
                                  @"coding_emoji_02": @" :吐: ",
                                  @"coding_emoji_03": @" :压力山大: ",
                                  @"coding_emoji_04": @" :忧伤: ",
                                  @"coding_emoji_05": @" :坏人: ",
                                  @"coding_emoji_06": @" :酷: ",
                                  @"coding_emoji_07": @" :哼: ",
                                  @"coding_emoji_08": @" :你咬我啊: ",
                                  @"coding_emoji_09": @" :内急: ",
                                  @"coding_emoji_10": @" :32个赞: ",
                                  @"coding_emoji_11": @" :加油: ",
                                  @"coding_emoji_12": @" :闭嘴: ",
                                  @"coding_emoji_13": @" :wow: ",
                                  @"coding_emoji_14": @" :泪流成河: ",
                                  @"coding_emoji_15": @" :NO!: ",
                                  @"coding_emoji_16": @" :疑问: ",
                                  @"coding_emoji_17": @" :耶: ",
                                  @"coding_emoji_18": @" :生日快乐: ",
                                  @"coding_emoji_19": @" :求包养: ",
                                  @"coding_emoji_20": @" :吹泡泡: ",
                                  @"coding_emoji_21": @" :睡觉: ",
                                  @"coding_emoji_22": @" :惊讶: ",
                                  @"coding_emoji_23": @" :Hi: ",
                                  @"coding_emoji_24": @" :打发点咯: ",
                                  @"coding_emoji_25": @" :呵呵: ",
                                  @"coding_emoji_26": @" :喷血: ",
                                  @"coding_emoji_27": @" :Bug: ",
                                  @"coding_emoji_28": @" :听音乐: ",
                                  @"coding_emoji_29": @" :垒码: ",
                                  @"coding_emoji_30": @" :我打你哦: ",
                                  @"coding_emoji_31": @" :顶足球: ",
                                  @"coding_emoji_32": @" :放毒气: ",
                                  @"coding_emoji_33": @" :表白: ",
                                  @"coding_emoji_34": @" :抓瓢虫: ",
                                  @"coding_emoji_35": @" :下班: ",
                                  @"coding_emoji_36": @" :冒泡: ",
                                  @"coding_emoji_38": @" :2015: ",
                                  @"coding_emoji_39": @" :拜年: ",
                                  @"coding_emoji_40": @" :发红包: ",
                                  @"coding_emoji_41": @" :放鞭炮: ",
                                  @"coding_emoji_42": @" :求红包: ",
                                  @"coding_emoji_43": @" :新年快乐: ",
                                  //猴子大表情 Gif
                                  @"coding_emoji_gif_01": @" :奔月: ",
                                  @"coding_emoji_gif_02": @" :吃月饼: ",
                                  @"coding_emoji_gif_03": @" :捞月: ",
                                  @"coding_emoji_gif_04": @" :打招呼: ",
                                  @"coding_emoji_gif_05": @" :悠闲: ",
                                  @"coding_emoji_gif_06": @" :赏月: ",
                                  @"coding_emoji_gif_07": @" :中秋快乐: ",
                                  @"coding_emoji_gif_08": @" :爬爬: ",
                                  //特殊 emoji 字符
                                  @"0️⃣":    @"0",
                                  @"1️⃣":    @"1",
                                  @"2️⃣":    @"2",
                                  @"3️⃣":    @"3",
                                  @"4️⃣":    @"4",
                                  @"5️⃣":    @"5",
                                  @"6️⃣":    @"6",
                                  @"7️⃣":    @"7",
                                  @"8️⃣":    @"8",
                                  @"9️⃣":    @"9",
                                  @"↩️":    @"\n",
                                  };
    });
    return _emotion_specail_dict;
}

- (NSString *)emotionSpecailName{
    return [NSString emotion_specail_dict][self];
}

@end
