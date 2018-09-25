//
//  ProjectMember.h
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
{
    alias = "";
    "created_at" = 1526459214000;
    id = 4429581;
    "last_visit_at" = 1534492843000;
    "project_id" = 2960845;
    type = 100;
    user =                 {
        avatar = "/static/fruit_avatar/Fruit-6.png";
        birthday = "";
        company = "";
        country = cn;
        "created_at" = 1524128478000;
        degree = 0;
        email = "";
        "email_validation" = 0;
        "fans_count" = 0;
        follow = 0;
        followed = 0;
        "follows_count" = 0;
        "global_key" = yuzebi;
        gravatar = "";
        id = 1288452;
        introduction = "";
        "is_member" = 0;
        "is_phone_validated" = 1;
        "last_logined_at" = 1535075173000;
        lavatar = "/static/fruit_avatar/Fruit-6.png";
        location = "";
        name = yuzebi;
        "name_pinyin" = "";
        path = "/u/yuzebi";
        phone = 18613973422;
        "phone_country_code" = "+86";
        "phone_validation" = 1;
        "points_left" = "0.2";
        school = "";
        sex = 2;
        slogan = "";
        status = 1;
        "tweets_count" = 0;
        "twofa_enabled" = 0;
        "updated_at" = 1535075176000;
        vip = 3;
        "vip_expired_at" = 1534694400000;
        website = "";
    };
    "user_id" = 1288452;
}
 */

#import <Foundation/Foundation.h>

@interface ProjectMember : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *project_id, *user_id, *type, *done, *processing;//type:80是member，100是creater
@property (readwrite, nonatomic, strong) User *user;
@property (readwrite, nonatomic, strong) NSDate *created_at, *last_visit_at;
@property (strong, nonatomic) NSString *alias, *editAlias;
@property (strong, nonatomic) NSNumber *editType;
+ (ProjectMember *)member_All;
- (NSString *)toQuitPath;
- (NSString *)toKickoutPath;
@end
