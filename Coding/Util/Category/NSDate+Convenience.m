//
//  NSDate+Convenience.m
//  Coding
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "NSDate+Convenience.h"

@implementation NSDate (Convenience)

static NSCalendar *_calendar = nil;
static NSDateFormatter *_displayFormatter = nil;

+ (void)initializeStatics {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if (_calendar == nil) {
                _calendar = [NSCalendar currentCalendar];
            }
            if (_displayFormatter == nil) {
                _displayFormatter = [[NSDateFormatter alloc] init];
            }
        }
    });
}

+ (NSCalendar *)sharedCalendar {
    [self initializeStatics];
    return _calendar;
}

+ (NSDateFormatter *)sharedDateFormatter {
    [self initializeStatics];
    return _displayFormatter;
}

//获取年
- (NSInteger)year {
    NSCalendar *calendar = [[self class] sharedCalendar];
    return [calendar component:NSCalendarUnitYear fromDate:self];
}

//获取月
- (NSInteger)month {
    NSCalendar *calendar = [[self class] sharedCalendar];
    return [calendar component:NSCalendarUnitMonth fromDate:self];
}

//获取日
- (NSInteger)day {
    NSCalendar *calendar = [[self class] sharedCalendar];
    return [calendar component:NSCalendarUnitDay fromDate:self];
}

//获取每个月的1号是该月中的第几天
- (NSInteger)firstWeekDayInMonth {
    //初始化
    NSCalendar *calendar = [[self class] sharedCalendar];
    //设置每周的第一天从星期几开始,1代表星期天,2代表星期一,默认为1
    [calendar setFirstWeekday:2];
    //获取日历信息
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    //设置日期为1号
    [comps setDay:1];
    //获取信息的日期
    NSDate *newDate = [calendar dateFromComponents:comps];
    //获取1号是在该月中的第几天
    return [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:newDate];
}

//获取该月的天数
- (NSInteger)numDaysInMonth {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
    return range.length;
}

//获取偏移多少年后的日期
- (NSDate *)offsetYear:(NSInteger)numYears {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:numYears];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

//获取偏移多少月后的日期
- (NSDate *)offsetMonth:(NSInteger)numMonths {
    NSCalendar *calendar = [[self class] sharedCalendar];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:numMonths];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

//获取偏移多少天后的日期
- (NSDate *)offsetDay:(NSInteger)numDays {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:numDays];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}

//获取偏移多少小时后的日期
- (NSDate *)offsetHour:(NSInteger)numHours {
    NSCalendar *calendar = [[self class] sharedCalendar];
    [calendar setFirstWeekday:2];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:numHours];
    return [calendar dateByAddingComponents:comps toDate:self options:0];
}


//日期转字符串
- (NSString *)stringWithFormat:(NSString *)format {
    [[[self class] sharedDateFormatter] setDateFormat:format];
    return [[[self class] sharedDateFormatter] stringFromDate:self];
}

//字符串转日期
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *formatter = [self sharedDateFormatter];
    [formatter setDateFormat:format];
    return [formatter dateFromString:string];
}

//根据当天的凌晨0点,获取距离多少天,0为当天,1为昨天,-1为明天
- (NSInteger)daysAgoAgainstMidnight {
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    //获取当天的凌晨0点
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [formatter dateFromString:[formatter stringFromDate:self]];
    
    return (int)[midnight timeIntervalSinceNow] / (60 * 60 * 24) * -1;
}

@end
