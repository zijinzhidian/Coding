//
//  NSDate+Common.h
//  Coding
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Convenience.h"

@interface NSDate (Common)

- (BOOL)isSameDay:(NSDate *)anotherDate;

- (NSInteger)leftDayCount;
- (NSInteger)secondsAgo;
- (NSInteger)minutesAgo;
- (NSInteger)hoursAgo;
- (NSInteger)monthsAgo;
- (NSInteger)yearsAgo;

- (NSString *)stringDisplay_HHmm;
- (NSString *)stringDisplay_MMdd;
- (NSString *)string_yyyy_MM_dd_EEE;
- (NSString *)string_yyyy_MM_dd;

- (NSString *)stringTimesAgo;       //代码更新时间

+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd;

@end
