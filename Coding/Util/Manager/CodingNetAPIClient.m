//
//  CodingNetAPIClient.m
//  Coding
//
//  Created by apple on 2018/4/20.
//  Copyright © 2018年 zjbojin. All rights reserved.
//

#import "CodingNetAPIClient.h"
#import "Login.h"

#define kNetworkMethodName @[@"Get", @"Post", @"Put", @"Delete"]

static CodingNetAPIClient *_sharedClient = nil;

@implementation CodingNetAPIClient

+ (CodingNetAPIClient *)sharedJsonClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CodingNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSObject baseURLStr]]];
    });
    return _sharedClient;
}

+ (instancetype)changeJsonClient {
    _sharedClient = [[CodingNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[NSObject baseURLStr]]];
    return _sharedClient;
}

#pragma mark - Init
- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        
        //数据返回类型
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        //设置ContentType
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        
        //设置HTTP头部
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
        
        //是否信任非法或过期的证书(一般来说，每个版本的iOS设备中,都会包含一些既有的CA根证书。如果接收到的证书是iOS信任的CA根证书签名的，那么则为合法证书；否则则为“非法”证书)
//        self.securityPolicy.allowInvalidCertificates = YES;
        
    }
    return self;
}

#pragma mark - Public Actions
- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)method
                       andBlock:(void(^)(id data, NSError *error))block {
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:method autoShowError:YES andBlock:block];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)method
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void(^)(id data, NSError *error))block {
    if (!aPath || aPath.length <= 0) return;
    
    //CSRF - 跨站请求伪造
    
    //Log请求数据
    DebugLog(@"\n===========request===========\n%@\n%@:\n%@", kNetworkMethodName[method], aPath, params);
    
    //对汉字进行编码
    aPath = [aPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //发送请求
    switch (method) {
        //所有Get请求,添加缓存机制
        case Get: {
            NSMutableString *localPath = [aPath mutableCopy];       //保存到本地的接口路径
            if (params) {
                [localPath appendString:params.description];    //若有参数,则拼接参数
            }
            [self GET:aPath parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    responseObject =  [NSObject loadResponseWithPath:localPath];  //加载缓存数据
                    block(responseObject, error);
                } else {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        //判断数据是否符合预期，给出提示
                        if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                            if (responseObject[@"data"][@"too_many_files"]) {
                                if (autoShowError) {
                                    [NSObject showHudTipStr:@"文件太多,不能正常显示"];
                                }
                            }
                        }
                        //缓存数据至本地
                        [NSObject saveResponseData:responseObject toPath:localPath];
                    }
                    block(responseObject, nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                DebugLog(@"\n+++++++++response+++++++++\n%@:\n%@", aPath, error);
                id responseObject = [NSObject loadResponseWithPath:localPath];
                //若autoShowEror为true && (错误不是NSURLErrorNotConnectedToInternet && 缓存的数据为空),则展示错误信息
                !autoShowError || (error.code == NSURLErrorNotConnectedToInternet && responseObject != nil) || [NSObject showError:error];
                block(responseObject, error);
                
            }];
        }
            break;
        
        case Post: {
            [self POST:aPath parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                } else {
                    block(responseObject, nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                DebugLog(@"\n+++++++++response+++++++++\n%@:\n%@", aPath, error);
                !autoShowError || [NSObject showError:error];
                block(nil, error);
                
            }];
        }
            break;
        
        case Put: {
            [self PUT:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                } else {
                    block(responseObject, nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                DebugLog(@"\n+++++++++response+++++++++\n%@:\n%@", aPath, error);
                !autoShowError || [NSObject showError:error];
                block(nil, error);
                
            }];
        }
            break;
            
        case Delete: {
            [self DELETE:aPath parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                DebugLog(@"\n===========response===========\n%@:\n%@", aPath, responseObject);
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                } else {
                    block(responseObject, nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                DebugLog(@"\n+++++++++response+++++++++\n%@:\n%@", aPath, error);
                !autoShowError || [NSObject showError:error];
                block(nil, error);
                
            }];
        }
            break;
    }
}


- (void)uploadImage:(UIImage *)image
               path:(NSString *)path
               name:(NSString *)name
       successBlock:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failureBlock:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
      progressBlock:(void (^)(CGFloat progressValue))progress {
    
    NSData *data = [image dataForCodingUpload];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg",[Login curLoginUser].global_key, [NSUUID UUID].UUIDString];
    
    __weak typeof(self) weakSelf = self;
    void (^uploadBlock)(NSDictionary *) = ^(NSDictionary *uploadParams) {
        [weakSelf POST:path parameters:uploadParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            NSString *progressString  = [NSString stringWithFormat:@"%.3f",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount];
            if (progress) {
                progress(progressString.floatValue);
            }
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            id error = [weakSelf handleResponse:responseObject];
            if (error && failure) {
                failure(task, error);
            } else {
                success(task, responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task, error);
            }
        }];
    };
    
    if ([path isEqualToString:@"https://up.qbox.me/"]) {        //先拿token
        NSDictionary *params = @{
                                 @"fileName": fileName,
                                 @"fileSize": @(data.length)
                                 };
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/upload_token/public/images" withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                NSDictionary *result = data[@"data"];
                NSMutableDictionary *uploadParams = @{}.mutableCopy;
                uploadParams[@"token"] = result[@"uptoken"];
                uploadParams[@"x:time"] = result[@"time"];
                uploadParams[@"x:authToken"] = result[@"authToken"];
                uploadParams[@"x:userId"] = result[@"userId"];
                uploadParams[@"key"] = fileName;
                uploadBlock(uploadParams);
            }
        }];
    } else {
        uploadBlock(nil);
    }
    
}

@end
