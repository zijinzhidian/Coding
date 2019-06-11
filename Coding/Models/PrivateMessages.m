//
//  PrivateMessages.m
//  Coding
//
//  Created by apple on 2019/5/17.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "PrivateMessages.h"

@interface PrivateMessages ()
@property(nonatomic, strong)NSNumber *p_lastId;
@end

@implementation PrivateMessages

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"PrivateMessage", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = _isPolling = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _curFriend = nil;
    }
    return self;
}

+ (PrivateMessages *)priMsgsWithUser:(User *)user {
    PrivateMessages *priMsgs = [[PrivateMessages alloc] init];
    priMsgs.curFriend = user;
    return priMsgs;
}

+ (id)analyzeResponseData:(NSDictionary *)responseData {
    id data = [responseData valueForKeyPath:@"data"];
    if (!data) {
        data = responseData;
    }
    id resultA = nil;
    if ([data isKindOfClass:[NSArray class]]) {
        resultA = [NSObject arrayFromJSON:data ofObjects:@"PrivateMessage"];
    }else if (data){
        resultA = [NSObject objectOfClass:@"PrivateMessages" fromJSON:data];
    }
    return resultA;
}

#pragma mark - Request path and params
- (NSString *)localPrivateMessagesPath {
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"conversations_%@", _curFriend.global_key];
    } else {
        path = @"conversations";
    }
    return path;
}

- (NSString *)toPath {
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"api/message/conversations/%@/prev", _curFriend.global_key];
    } else {
        path = @"api/message/conversations";
    }
    return path;
}

- (NSDictionary *)toParams {
    NSDictionary *params = nil;
    if (_curFriend) {
        NSNumber *prevId = kDefaultLastId;
        if (_willLoadMore && _list.count > 0) {
            PrivateMessage *prev_Msg = [_list lastObject];
            prevId = prev_Msg.id;
        }
        params = @{@"id": prevId,
                   @"pageSize": _pageSize};
    } else {
        params = @{@"page": _willLoadMore ? [NSNumber numberWithInt:_page.intValue + 1] : [NSNumber numberWithInt:1],
                   @"pageSize": _pageSize};
    }
    return params;
}

#pragma mark - Poll path and params
- (NSString *)toPollPath {
    return [NSString stringWithFormat:@"api/message/conversations/%@/last", _curFriend.global_key];
}

- (NSDictionary *)toPollParams {
    return @{@"id" : self.p_lastId};
}

#pragma mark - Public Methods
- (void)configWithObj:(id)anObj {
    if ([anObj isKindOfClass:[PrivateMessages class]]) {
        PrivateMessages *priMsgs = (PrivateMessages *)anObj;
        self.page = priMsgs.page;
        self.pageSize = priMsgs.pageSize;
        self.totalPage = priMsgs.totalPage;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:priMsgs.list];
        self.canLoadMore = _page.intValue < _totalPage.intValue;
    } else if ([anObj isKindOfClass:[NSArray class]]) {
        NSArray *list = (NSArray *)anObj;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:list];
        self.canLoadMore = list.count > 0;
    }
    [self reset_dataList];
}

#pragma mark - Private Methods
- (NSMutableArray *)reset_dataList {
    [self.dataList removeAllObjects];
    if (_list.count > 0) {
        self.dataList = [_list mutableCopy];
    }
    if (_nextMessages.count > 0) {
        [self.dataList insertObjects:_nextMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _nextMessages.count)]];
    }
    return _dataList;
}

#pragma mark - Getter And Setters
- (NSNumber *)p_lastId {
    if (!_p_lastId) {
        _p_lastId = @(0);
        [_list enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id.integerValue > 0) {
                self->_p_lastId = obj.id;
                *stop = YES;
            }
        }];
    }
    return _p_lastId;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (NSMutableArray *)list{
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray *)nextMessages{
    if (!_nextMessages) {
        _nextMessages = [[NSMutableArray alloc] init];
    }
    return _nextMessages;
}


@end
