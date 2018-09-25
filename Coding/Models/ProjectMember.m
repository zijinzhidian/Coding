//
//  ProjectMember.m
//  Coding
//
//  Created by apple on 2018/8/23.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "ProjectMember.h"

@implementation ProjectMember
+ (ProjectMember *)member_All{
    ProjectMember *mem = [[ProjectMember alloc] init];
    mem.user_id = [NSNumber numberWithInteger:-1];
    mem.user = nil;
    return mem;
}

- (NSString *)editAlias{
    if (!_editAlias) {
        _editAlias = _alias ?: @"";
    }
    return _editAlias;
}

- (NSNumber *)editType{
    if (!_editType) {
        _editType = _type;
    }
    return _editType;
}

- (NSString *)toQuitPath{
    return [NSString stringWithFormat:@"api/project/%d/quit", _project_id.intValue];
}

- (NSString *)toKickoutPath{
    return [NSString stringWithFormat:@"api/project/%@/kickout/%@", _project_id.stringValue, _user_id.stringValue];
}

@end
