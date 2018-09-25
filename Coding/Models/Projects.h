//
//  Projects.h
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

/*
{
    "code": 0,
    "data": {
        "list": [
                 {
                     "created_at": 1526459214000,
                     "backend_project_path": "/user/yuzebi/project/haha",
                     "description": "",
                     "git_url": "git://git.coding.net/yuzebi/haha.git",
                     "ssh_url": "git@git.coding.net:yuzebi/haha.git",
                     "svn_url": "svn+ssh://svn@svn.coding.net/yuzebi/haha",
                     "is_public": true,
                     "https_url": "https://git.coding.net/yuzebi/haha.git",
                     "vcs_type": "git",
                     "subversion_url": "subversion.coding.net/yuzebi/haha",
                     "id": 2960845,
                     "name": "haha",
                     "owner_id": 1288452,
                     "owner_user_name": "yuzebi",
                     "owner_user_picture": "/static/fruit_avatar/Fruit-6.png",
                     "owner_user_home": "<a href=\"https://coding.net/u/yuzebi\">yuzebi</a>",
                     "project_path": "/u/yuzebi/p/haha",
                     "status": 1,
                     "type": 1,
                     "updated_at": 1526459214000,
                     "fork_count": 0,
                     "star_count": 0,
                     "watch_count": 0,
                     "pin": false,
                     "depot_path": "/u/yuzebi/p/haha/git",
                     "forked": false,
                     "un_read_activities_count": 0,
                     "icon": "https://dn-coding-net-production-static.qbox.me/36be853e-1487-40a8-993c-e181cd80cdfe.jpg",
                     "current_user_role_id": 0,
                     "stared": false,
                     "watched": false,
                     "recommended": 0,
                     "max_member": 20,
                     "groupId": 0,
                     "plan": 1,
                     "isTeam": false
                 },
                 {
                     "created_at": 1526278366000,
                     "backend_project_path": "/user/yuzebi/project/test",
                     "description": "",
                     "git_url": "git://git.coding.net/yuzebi/test.git",
                     "ssh_url": "git@git.coding.net:yuzebi/test.git",
                     "svn_url": "svn+ssh://svn@svn.coding.net/yuzebi/test",
                     "is_public": false,
                     "https_url": "https://git.coding.net/yuzebi/test.git",
                     "vcs_type": "git",
                     "subversion_url": "subversion.coding.net/yuzebi/test",
                     "id": 2942232,
                     "name": "test",
                     "owner_id": 1288452,
                     "owner_user_name": "yuzebi",
                     "owner_user_picture": "/static/fruit_avatar/Fruit-6.png",
                     "owner_user_home": "<a href=\"https://coding.net/u/yuzebi\">yuzebi</a>",
                     "project_path": "/u/yuzebi/p/test",
                     "status": 1,
                     "type": 2,
                     "updated_at": 1526278366000,
                     "fork_count": 0,
                     "star_count": 0,
                     "watch_count": 0,
                     "pin": false,
                     "depot_path": "/u/yuzebi/p/test/git",
                     "forked": false,
                     "un_read_activities_count": 0,
                     "icon": "https://dn-coding-net-production-static.qbox.me/5e3dfecf-edd1-4a73-a8a0-39c2142ffa9e.jpg",
                     "current_user_role_id": 0,
                     "stared": false,
                     "watched": false,
                     "recommended": 0,
                     "max_member": 20,
                     "groupId": 0,
                     "plan": 1,
                     "isTeam": false
                 }
                 ],
        "page": 1,
        "pageSize": 10,
        "totalPage": 1,
        "totalRow": 2
    }
}
*/

#import <Foundation/Foundation.h>
#import "Project.h"


typedef NS_ENUM(NSInteger, ProjectsType) {
    ProjectsTypeAll = 0,            //我的全部项目
    ProjectsTypeCreated,            //我创建的
    ProjectsTypeCreatedPrivate,     //我创建的私有的
    ProjectsTypeCreatedPublic,      //我创建的公开的
    ProjectsTypeJoined,             //我参与的
    ProjectsTypeWatched,            //我关注的
    ProjectsTypeStared,             //我收藏的
    
    ProjectsTypeToChoose,
    
    ProjectsTypeTaProject,          //别人的项目
    ProjectsTypeTaStared,           //收藏的别人的项目
    ProjectsTypeTaWatched,          //关注的别人的项目
    
    ProjectsTypeAllPublic           //项目广场
};

@interface Projects : NSObject

@property(nonatomic,strong)User *curUser;              //用户数据
@property(nonatomic,assign)ProjectsType type;       //项目类型

//分页请求
@property(nonatomic,strong)NSNumber *page, *pageSize;
@property(nonatomic,assign)BOOL canLoadMore, willLoadMore, isLoading;

//解析
@property(nonatomic,strong)NSMutableArray *list;                //所有项目数据
@property(nonatomic,strong)NSNumber *totalPage, *totalRow;      //总共页数、项目数量
@property(nonatomic,strong)NSDictionary *propertyArrayMap;      //属性字典
@property(nonatomic,strong,readonly)NSArray *pinList, *noPinList;

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user;
- (NSDictionary *)toParams;
- (NSString *)toPath;
- (void)configWithProjects:(Projects *)responsePros;        //设置数据

@end
