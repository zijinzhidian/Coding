//
//  Project.m
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Project.h"

@implementation Project

- (NSString *)toDetailPath {
    return [NSString stringWithFormat:@"api/user/%@/project/%@", self.owner_user_name, self.name];
}

- (NSString *)toBranchOrTagPath:(NSString *)path{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@", self.owner_user_name, self.name, path];
}


- (NSString *)toUpdatePath {
    return @"api/project";
}

- (NSDictionary *)toUpdateParams {
    return @{
             @"name": self.name,
             @"description": self.description_mine,
             @"id": self.id
             };
}

- (NSString *)toUpdateIconPath {
    return [NSString stringWithFormat:@"api/project/%@/project_icon",self.id];
}

- (NSString *)toDeletePath {
    return [NSString stringWithFormat:@"api/user/%@/project/%@",self.owner_user_name, self.name];
}

- (NSString *)toArchivePath {
    return [NSString stringWithFormat:@"api/project/%@/archive", self.id];
}

- (NSString *)toMembersPath{
    if ([_id isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"api/project/%d/members", self.id.intValue];
    } else {
        return [NSString stringWithFormat:@"api/user/%@/project/%@/members", self.owner_user_name, self.name];
    }
}

- (NSDictionary *)toMembersParams {
    return @{
             @"page": @1,
             @"pageSize": @500
             };
}

- (NSString *)localMembersPath {
    return [NSString stringWithFormat:@"%@_MembersPath",self.id.stringValue];
}

@end
