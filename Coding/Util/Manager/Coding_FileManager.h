//
//  Coding_FileManager.h
//  Coding
//
//  Created by apple on 2019/5/16.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Coding_UploadTask;

NS_ASSUME_NONNULL_BEGIN

@interface Coding_FileManager : NSObject

+ (Coding_FileManager *)sharedManager;

#pragma mark - Upload
/**
 将上传的图片资源对象写入磁盘

 @param fileName 文件名称
 @param asset 图片资源对象
 @return 是否写入成功
 */
+ (BOOL)writeUploadDataWithFileName:(NSString *)fileName andAsset:(PHAsset *)asset;

/**
 将上传的图片对象写入磁盘

 @param fileName 文件名称
 @param image 图片对象
 @return 是否写入成功
 */
+ (BOOL)writeUploadDataWithFileName:(NSString *)fileName andImage:(UIImage *)image;

/**
 删除指定的上传数据

 @param fileName 需要删除的文件名称
 @return 是否删除成功
 */
+ (BOOL)deleteUploadDataWithFileName:(NSString *)fileName;

+ (Coding_UploadTask *)addUploadTaskWithFileName:(NSString *)fileName projectIsPublic:(BOOL)isPublic;

@end

NS_ASSUME_NONNULL_END


@interface Coding_DownloadTask : NSObject

@property(nonatomic, strong)NSURLSessionDownloadTask *task;         //下载任务
@property(nonatomic, strong)NSProgress *progress;                   //下载进度
@property(nonatomic, strong)NSString *diskFileName;                 //下载后保存至磁盘的文件名称

+ (Coding_DownloadTask *)cDownloadTaskWithTask:(NSURLSessionDownloadTask *)task
                                      progress:(NSProgress *)progress
                                      fileName:(NSString *)fileName;
- (void)cancel;

@end


@interface Coding_UploadTask : NSObject

@property(nonatomic, strong)NSURLSessionUploadTask *task;           //上传任务
@property(nonatomic, strong)NSProgress *progress;                   //上传进度
@property(nonatomic, strong)NSString *fileName;                     //上传文件名称

+ (Coding_UploadTask *)cUploadTaskWithTask:(NSURLSessionUploadTask *)task
                                  progress:(NSProgress *)progress
                                  fileName:(NSString *)fileName;
- (void)cancel;

@end
