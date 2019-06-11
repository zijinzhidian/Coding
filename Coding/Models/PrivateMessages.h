//
//  PrivateMessages.h
//  Coding
//
//  Created by apple on 2019/5/17.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PrivateMessages : NSObject

//分页请求
@property(nonatomic, strong)NSNumber *page, *pageSize;
@property(nonatomic, assign)BOOL canLoadMore, willLoadMore, isLoading, isPolling;

//解析
@property(nonatomic, strong)NSMutableArray *list, *nextMessages ,*dataList;     //项目数据
@property(nonatomic, strong)NSNumber *totalPage, *totalRow;      //总共页数、项目数量
@property(nonatomic, strong)NSDictionary *propertyArrayMap;      //属性字典
@property(nonatomic, strong)User *curFriend;                     //当前发消息的好友

#pragma mark - Init
+ (PrivateMessages *)priMsgsWithUser:(User *)user;
+ (id)analyzeResponseData:(NSDictionary *)responseData;

- (void)configWithObj:(id)anObj;

#pragma mark - Request path and params
- (NSString *)localPrivateMessagesPath;
- (NSString *)toPath;
- (NSDictionary *)toParams;

#pragma mark - Poll path and params
- (NSString *)toPollPath;
- (NSDictionary *)toPollParams;

@end

NS_ASSUME_NONNULL_END
