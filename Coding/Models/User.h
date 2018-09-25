//
//  User.h
//  Coding
//
//  Created by apple on 2018/4/25.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic,copy,readwrite)NSString *avatar, *name, *global_key, *path, *slogan, *company, *tags_str, *tags, *location, *job_str, *email, *birthday, *pinyinName;
@property(nonatomic,copy,readwrite)NSString *curPassword, *resetPassword, *resetPasswordConfirm, *phone, *introduction, *phone_country_code, *country, *school;

@property(nonatomic,strong,readwrite)NSNumber *id, *sex, *follow, *followed, *fans_count, *follows_count, *tweets_count, *status, *points_left, *email_validation, *is_phone_validated, *vip, *degree, *job;

@property(nonatomic,strong,readwrite)NSDate *created_at, *last_logined_at, *last_activity_at, *updated_at, *vip_expired_at;

@end
