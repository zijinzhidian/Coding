//
//  CodingNetAPIClient.h
//  Coding
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, NetworkMethod) {
    Get = 0,
    Post,
    Put,
    Delete
};

@interface CodingNetAPIClient : AFHTTPSessionManager

+ (CodingNetAPIClient *)sharedJsonClient;
+ (instancetype)changeJsonClient;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void(^)(id data, NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)method
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void(^)(id data, NSError *error))block;

- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
               name:(NSString *)name
       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
      progressBlock:(void (^)(CGFloat progressValue))progress;

@end
