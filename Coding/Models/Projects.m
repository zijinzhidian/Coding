//
//  Projects.m
//  Coding
//
//  Created by apple on 2018/5/14.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "Projects.h"

@implementation Projects

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.canLoadMore = NO;
        self.isLoading = NO;
        self.willLoadMore = NO;
        self.propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:@"Project", @"list", nil];
    }
    return self;
}

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user {
    Projects *pros = [[Projects alloc] init];
    pros.type = type;
    pros.curUser = user;
    
    pros.page = @1;;
    pros.pageSize = @99999999;
    return pros;
}

#pragma mark - Public Actions
- (NSDictionary *)toParams{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:
                                   @{@"page" : [NSNumber numberWithInteger:_willLoadMore? self.page.integerValue+1 : 1],
                                     @"pageSize" : self.pageSize,
                                     @"type" : [self typeStr]}];
    if (self.type == ProjectsTypeAll) {
        [params setObject:@"hot" forKey:@"sort"];
    }
    return params;
}

- (NSString *)toPath {
    NSString *path;
    if (self.type==ProjectsTypeAllPublic) {
        path = @"api/public/all";
    }else if (self.type >= ProjectsTypeTaProject && self.type < ProjectsTypeAllPublic) {
        path = [NSString stringWithFormat:@"api/user/%@/public_projects", _curUser.global_key];
    }else{
        path = @"api/projects";
    }
    return path;
}

- (void)configWithProjects:(Projects *)responsePros {
    self.page = responsePros.page;
    self.totalRow = responsePros.totalRow;
    self.totalPage = responsePros.totalPage;
    self.canLoadMore = self.page.integerValue < self.totalPage.integerValue;
    
    //对数组进行筛选
    NSArray *projectList = responsePros.list;
    if (self.type == ProjectsTypeToChoose) {
        //筛选出私有的项目
        projectList = [projectList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_public == %d", NO]];
    } else if (self.type == ProjectsTypeCreatedPrivate || self.type == ProjectsTypeCreatedPublic){
        projectList = [projectList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_public == %d", (self.type == ProjectsTypeCreatedPublic)]];
    }
    
    if (!projectList) {
        return;
    }
    
    if (self.willLoadMore) {
        [self.list addObjectsFromArray:projectList];
    } else {
        self.list = [NSMutableArray arrayWithArray:projectList];
    }
}

#pragma mark - Private Actions
- (NSString *)typeStr{
    NSString *typeStr;
    switch (self.type) {
        case  ProjectsTypeAll:
        case  ProjectsTypeToChoose:
            typeStr = @"all";
            break;
        case ProjectsTypeJoined:
            typeStr = @"joined";
            break;
        case ProjectsTypeCreated:
        case ProjectsTypeCreatedPrivate:
        case ProjectsTypeCreatedPublic:
            typeStr = @"created";
            break;
        case  ProjectsTypeTaProject:
            typeStr = @"project";
            break;
        case  ProjectsTypeTaStared:
            typeStr = @"stared";
            break;
        case  ProjectsTypeTaWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeStared:
            typeStr = @"stared";
            break;
        default:
            typeStr = @"all";
            break;
    }
    return typeStr;
}

#pragma mark - Getters
- (NSArray *)pinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 1"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}

- (NSArray *)noPinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 0"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}

@end
