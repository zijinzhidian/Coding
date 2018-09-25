//
//  Project.h
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
/*
{
    "created_at": 1500866689000,
    "backend_project_path": "/user/beldon/project/spring-cloud-learn",
    "description": "",
    "git_url": "git://git.coding.net/beldon/spring-cloud-learn.git",
    "ssh_url": "git@git.coding.net:beldon/spring-cloud-learn.git",
    "svn_url": "svn+ssh://svn@svn.coding.net/beldon/spring-cloud-learn",
    "is_public": true,
    "https_url": "https://git.coding.net/beldon/spring-cloud-learn.git",
    "vcs_type": "git",
    "subversion_url": "subversion.coding.net/beldon/spring-cloud-learn",
    "id": 1299967,
    "name": "spring-cloud-learn",
    "owner_id": 81802,
    "owner_user_name": "beldon",
    "owner_user_picture": "/static/fruit_avatar/Fruit-11.png",
    "owner_user_home": "<a href=\"https://coding.net/u/beldon\">beldon</a>",
    "project_path": "/u/beldon/p/spring-cloud-learn",
    "status": 1,
    "type": 1,
    "updated_at": 1500866689000,
    "fork_count": 0,
    "star_count": 0,
    "watch_count": 0,
    "pin": false,
    "depot_path": "/u/beldon/p/spring-cloud-learn/git",
    "forked": false,
    "un_read_activities_count": 0,
    "icon": "/static/project_icon/scenery-16.png",
    "current_user_role_id": 0,
    "stared": false,
    "watched": false,
    "recommended": 0,
    "max_member": 20,
    "groupId": 0,
    "plan": 1,
    "isTeam": false
},
*/
 
#import <Foundation/Foundation.h>

@interface Project : NSObject
/*
 pin:项目是否为常用
 description_mine:项目描述
 */
@property(nonatomic,strong)NSString *icon, *name, *owner_user_name, *backend_project_path, *full_name, *description_mine, *path, *parent_depot_path, *current_user_role,*project_path;
@property(nonatomic,strong)NSNumber *id, *owner_id, *is_public, *un_read_activities_count, *done, *processing, *star_count, *stared, *watch_count, *watched, *fork_count, *forked, *recommended, *pin, *current_user_role_id, *type, *gitReadmeEnabled, *max_member;
@property(nonatomic,assign)BOOL isStaring, isWatching, isLoadingMember, isLoadingDetail;

@property(nonatomic,strong)User *owner;
@property(nonatomic,strong)NSDate *created_at,*updated_at;

//项目详情接口路径
- (NSString *)toDetailPath;

//标签或分支接口路径
- (NSString *)toBranchOrTagPath:(NSString *)path;

//更新项目接口路径
- (NSString *)toUpdatePath;
//更新项目接口参数
- (NSDictionary *)toUpdateParams;

//更新项目图标接口路径
- (NSString *)toUpdateIconPath;

//删除项目接口路径
- (NSString *)toDeletePath;

//归档项目接口路径
- (NSString *)toArchivePath;

//获取项目成员列表接口路径
- (NSString *)toMembersPath;
//获取项目成员列表接口参数
- (NSDictionary *)toMembersParams;
//存储成员列表数据至本地的路径
- (NSString *)localMembersPath;

@end
