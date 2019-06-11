//
//  Coding_FileManager.m
//  Coding
//
//  Created by apple on 2019/5/16.
//  Copyright © 2019年 zjbojin. All rights reserved.
//

#import "Coding_FileManager.h"

@implementation Coding_FileManager

+ (Coding_FileManager *)sharedManager {
    static Coding_FileManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[Coding_FileManager alloc] init];
    });
    return _sharedManager;
}


/**
 上传路径
 */
+ (NSString *)uploadPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *uploadPath = [documentPath stringByAppendingPathComponent:@"Coding_Upload"];
    return uploadPath;
}


/**
 下载路径
 */
+ (NSString *)downloadPath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"Coding_Download"];
    return downloadPath;
}

/**
 创建文件夹

 @param path 文件夹路径
 @return 是否创建成功
 */
+ (BOOL)createFolder:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;        //是否为文件夹
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];  //文件是否存在
    BOOL isCreated = NO;    //是否创建成功
    if (!(isDir == YES && existed == YES)) {
        isCreated = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        isCreated = YES;
    }
    if (isCreated) {
        [NSURL addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path isDirectory:YES]];
    }
    return isCreated;
}

#pragma mark - Upload
+ (BOOL)writeUploadDataWithFileName:(NSString *)fileName andAsset:(PHAsset *)asset {
    //若创建文件夹失败则直接返回NO
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
    //文件路径
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    //创建文件
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    //打开一个文件准备写入
    NSFileHandle *handel = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //如果NSFileHandle对象不存在,返回NO
    if (!handel) {
        return NO;
    }
    NSLog(@"~~~~%@",filePath);
    //将data数据写入文件
    [handel writeData:asset.loadImageData];
    
    return YES;
}

+ (BOOL)writeUploadDataWithFileName:(NSString *)fileName andImage:(UIImage *)image {
    //若创建文件夹失败则直接返回NO
    if (![self createFolder:[self uploadPath]]) {
        return NO;
    }
    //文件路径
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    //写入磁盘
    return [[image dataForCodingUpload] writeToFile:filePath options:NSAtomicWrite error:nil];
}

+ (BOOL)deleteUploadDataWithFileName:(NSString *)fileName {
    NSString *filePath = [[self uploadPath] stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [fileManager removeItemAtPath:fileName error:nil];
    }else{
        return YES;
    }
}

+ (Coding_UploadTask *)addUploadTaskWithFileName:(NSString *)fileName projectIsPublic:(BOOL)isPublic {
    if (!fileName) {
        return nil;
    }
    //NSString *fileName = [NSString stringWithFormat:@"%@|||%@|||%@", self.curProject.id.stringValue, @"0", originalFileName];
    NSArray *fileInfos = [fileName componentsSeparatedByString:@"|||"];
    if (fileInfos.count != 3) {
        return nil;
    }
    NSString *project_id, *folder_id, *name;
    project_id = fileInfos[0];
    folder_id = fileInfos[1];
    name = fileInfos[2];
    return nil;
}

@end


@implementation Coding_DownloadTask

+ (Coding_DownloadTask *)cDownloadTaskWithTask:(NSURLSessionDownloadTask *)task progress:(NSProgress *)progress fileName:(NSString *)fileName{
    Coding_DownloadTask *cDownloadTask = [[Coding_DownloadTask alloc] init];
    cDownloadTask.task = task;
    cDownloadTask.progress = progress;
    cDownloadTask.diskFileName = fileName;
    return cDownloadTask;
}

- (void)cancel{
    if (self.task && (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended)) {
        [self.task cancel];
    }
}

@end


@implementation Coding_UploadTask

+ (Coding_UploadTask *)cUploadTaskWithTask:(NSURLSessionUploadTask *)task
                                  progress:(NSProgress *)progress
                                  fileName:(NSString *)fileName {
    Coding_UploadTask *cUploadTask = [[Coding_UploadTask alloc] init];
    cUploadTask.task = task;
    cUploadTask.progress = progress;
    cUploadTask.fileName = fileName;
    return cUploadTask;
}

- (void)cancel {
    if (self.task && (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended)) {
        [self.task cancel];
    }
}

@end

