//
//  NSDate+Common.m
//  Coding
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

//判断都是为同一天
- (BOOL)isSameDay:(NSDate *)anotherDate {
    NSDateComponents *compsSelf = [[[self class] sharedCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    NSDateComponents *compsAnother = [[[self class] sharedCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:anotherDate];
    return (compsSelf.year == compsAnother.year) && (compsSelf.month == compsAnother.month) && (compsSelf.day == compsAnother.day);
}

//获取当前日期距离某一天剩余的天数
- (NSInteger)leftDayCount {
    //当前年月日,时分清零
    NSDate *today = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];
    //指定日期年月日,时分清零
    NSDate *selfCopy = [NSDate dateFromString:[self stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];
    //比较两个日期的差异
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitDay fromDate:today toDate:selfCopy options:0];
    return comps.day;
}

//获取秒数差
- (NSInteger)secondsAgo {
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitSecond fromDate:self toDate:[NSDate date] options:0];
    return comps.second;
}

//获取分数差
- (NSInteger)minutesAgo {
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitMinute fromDate:self toDate:[NSDate date] options:0];
    return comps.minute;
}

//获取小时差
- (NSInteger)hoursAgo {
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitHour fromDate:self toDate:[NSDate date] options:0];
    return comps.hour;
}

//获取月份差
- (NSInteger)monthsAgo {
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitMonth fromDate:self toDate:[NSDate date] options:0];
    return comps.month;
}

//获取年数差
- (NSInteger)yearsAgo {
    NSDateComponents *comps = [[[self class] sharedCalendar] components:NSCalendarUnitYear fromDate:self toDate:[NSDate date] options:0];
    return comps.year;
}

- (NSString *)stringDisplay_HHmm {
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {     //不是当前年
        displayStr = [self stringWithFormat:@"yy/MM/dd HH:mm"];
    } else if ([self leftDayCount] != 0) {         //不是当前天
        displayStr = [self stringWithFormat:@"MM/dd HH:mm"];
    } else if ([self hoursAgo] > 0) {              //一小时以上
        displayStr = [self stringWithFormat:@"今天 HH:mm"];
    } else if ([self minutesAgo] > 0) {             //一分钟以上
        displayStr = [NSString stringWithFormat:@"%ld 分钟前",[self minutesAgo]];
    } else if ([self secondsAgo] > 10) {            //10秒钟以上
        displayStr = [NSString stringWithFormat:@"%ld 秒前",[self secondsAgo]];
    } else {
        displayStr = @"刚刚";
    }
    return displayStr;
}

- (NSString *)stringDisplay_MMdd {
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {     //不是当前年
        displayStr = [self stringWithFormat:@"yy/MM/dd"];
    } else if ([self leftDayCount] != 0) {         //不是当前天
        displayStr = [self stringWithFormat:@"MM/dd"];
    } else if ([self hoursAgo] > 0) {              //一小时以上
        displayStr = [self stringWithFormat:@"今天"];
    } else if ([self minutesAgo] > 0) {             //一分钟以上
        displayStr = [NSString stringWithFormat:@"%ld 分钟前",[self minutesAgo]];
    } else if ([self secondsAgo] > 10) {            //10秒钟以上
        displayStr = [NSString stringWithFormat:@"%ld 秒前",[self secondsAgo]];
    } else {
        displayStr = @"刚刚";
    }
    return displayStr;
}

- (NSString *)string_yyyy_MM_dd_EEE {
    NSString *displayStr = [self stringWithFormat:@"yyyy-MM-dd EEE"];
    NSInteger daysAgo = [self daysAgoAgainstMidnight];
    switch (daysAgo) {
        case 0:
            displayStr = [displayStr stringByAppendingString:@" (今天) "];
            break;
        case 1:
            displayStr = [displayStr stringByAppendingString:@" (昨天) "];
            break;
        default:
            break;
    }
    return displayStr;
}

- (NSString *)string_yyyy_MM_dd {
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

//代码更新时间
- (NSString *)stringTimesAgo {
    if ([self compare:[NSDate date]] == NSOrderedDescending) {
        return @"刚刚";
    }
    
    NSString *text = nil;
    NSInteger agoCount = [self yearsAgo];
    if (agoCount > 0) {
        text = [NSString stringWithFormat:@"%ld年前",agoCount];
    } else {
        agoCount = [self monthsAgo];
        if (agoCount > 0) {
            text = [NSString stringWithFormat:@"%ld个月前",agoCount];
        } else {
            agoCount = [self daysAgoAgainstMidnight];
            if (agoCount > 0) {
                text = [NSString stringWithFormat:@"%ld天前",agoCount];
            } else {
                agoCount = [self hoursAgo];
                if (agoCount > 0) {
                    text = [NSString stringWithFormat:@"%ld小时前",agoCount];
                } else {
                    agoCount = [self minutesAgo];
                    if (agoCount > 0) {
                        text = [NSString stringWithFormat:@"%ld分钟前",agoCount];
                    } else {
                        agoCount = [self secondsAgo];
                        if (agoCount > 15) {
                            text = [NSString stringWithFormat:@"%ld秒前",agoCount];
                        } else {
                            text = @"刚刚";
                        }
                    }
                }
            }
        }
    }
    return text;
}

+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd {
    if (str_yyyy_MM_dd.length <= 0) {
        return nil;
    }
    NSDate *date = [NSDate dateFromString:str_yyyy_MM_dd withFormat:@"yyyy-MM-dd"];
    if (!date) {
        return nil;
    }
    NSString *displayStr = @"";
    if ([date year] != [[NSDate date] year]) {
        displayStr = [date stringWithFormat:@"yyyy年MM月dd日"];
    }else{
        switch ([date leftDayCount]) {
            case 2:
                displayStr = @"后天";
                break;
            case 1:
                displayStr = @"明天";
                break;
            case 0:
                displayStr = @"今天";
                break;
            case -1:
                displayStr = @"昨天";
                break;
            case -2:
                displayStr = @"前天";
                break;
            default:
                displayStr = [date stringWithFormat:@"MM月dd日"];
                break;
        }
    }
    return displayStr;
}

@end
