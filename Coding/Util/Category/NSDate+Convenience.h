//
//  NSDate+Convenience.h
//  Coding
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Convenience)

+ (NSCalendar *)sharedCalendar;
+ (NSDateFormatter *)sharedDateFormatter;

//获取年
- (NSInteger)year;
//获取月
- (NSInteger)month;
//获取日
- (NSInteger)day;

//获取每个月的1号是该月中的第几天
- (NSInteger)firstWeekDayInMonth;
//获取该月的天数
- (NSInteger)numDaysInMonth;

//获取偏移多少年后的日期
- (NSDate *)offsetYear:(NSInteger)numYears;
//获取偏移多少月后的日期
- (NSDate *)offsetMonth:(NSInteger)numMonths;
//获取偏移多少天后的日期
- (NSDate *)offsetDay:(NSInteger)numDays;
//获取偏移多少小时后的日期
- (NSDate *)offsetHour:(NSInteger)numHours;

//日期转字符串
- (NSString *)stringWithFormat:(NSString *)format;
//字符串转日期
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

//根据当天的凌晨0点,获取距离多少天,0为当天,1为昨天,-1为明天
- (NSInteger)daysAgoAgainstMidnight;

@end
