//
//  VPLDownloader.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLDownloader.h"
#import "VPLConstant.h"
#import "VPUPPathUtil.h"
#import "VPUPMD5Util.h"
#import "VPUPPrefetchManager.h"
#import "VPUPRandomUtil.h"

NSInteger const VPLDownloaderRetryCount = 2;

@implementation VPLDownloaderObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.statisticsList = [[VPUPTrafficStatisticsList alloc] init];
    }
    return self;
}

+ (instancetype)objectWithFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath {
    VPLDownloaderObject *loadObject = [[VPLDownloaderObject alloc] init];
    loadObject.filesList = filesList;
    
    NSMutableArray *filesUrl = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *filesName = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *file in filesList) {
        NSString *url = [file objectForKey:@"url"];
        [filesUrl addObject:url];
        NSString *fileName = [url lastPathComponent];
        [filesName addObject:fileName];
    }
    
    loadObject.filesUrl = filesUrl;
    loadObject.filesName = filesName;
    
    loadObject.destinationPath = destinationPath;
    loadObject.tempFilePath = [destinationPath stringByAppendingPathComponent:[NSString stringWithFormat:@"temp%@", [VPUPRandomUtil randomMKTempStringByLength:8]]];
    
    return loadObject;
}

@end


@interface VPLDownloader()

@property (nonatomic, strong) VPUPPrefetchManager *prefetchManager;
@property (nonatomic, strong) dispatch_queue_t downloaderQueue;

- (void)callbackComplete:(VPLDownloaderCompletionBlock)complete withError:(NSError *)error;

- (void)callbackComplete:(VPLDownloaderCompletionBlock)complete withError:(NSError *)error withStatistics:(VPUPTrafficStatisticsList *)trafficList;

@end


@implementation VPLDownloader

+ (instancetype)sharedDownloader {
    static VPLDownloader *_sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDownloader = [[self alloc] init];
    });
    return _sharedDownloader;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloaderQueue = dispatch_queue_create("com.videopls.lua.loader", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (VPUPPrefetchManager *)prefetchManager {
    if (!_prefetchManager) {
        _prefetchManager = [[VPUPPrefetchManager alloc] init];
    }
    return _prefetchManager;
}

- (void)checkAndDownloadFilesListWithAppInfo:(VPMiniAppInfo *)appInfo complete:(VPLDownloaderCompletionBlock)complete {
    if (appInfo && appInfo.mpID) {
        [self checkAndDownloadFilesList:appInfo.luaList resumePath:[VPUPPathUtil subPathOfLOSPath:appInfo.mpID] complete:complete];
    }
    else {
        NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3000 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"init data error"]}];
        [self callbackComplete:complete withError:error];
    }
}

- (void)checkAndDownloadFilesList:(NSArray *)filesList complete:(VPLDownloaderCompletionBlock)complete {
    [self checkAndDownloadFilesList:filesList resumePath:[VPUPPathUtil lOSPath] complete:complete];
}

- (void)checkAndDownloadFilesList:(NSArray *)filesList resumePath:(NSString *)resumePath complete:(VPLDownloaderCompletionBlock)complete {
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumePath]) {
        [self checkFilesListWithLocal:filesList resumePath:resumePath complete:complete];
    }
    else {
        NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3001 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"resumePath do not exists"]}];
        [self callbackComplete:complete withError:error];
    }
}

- (void)checkFilesListWithLocal:(NSArray *)fileList resumePath:(NSString *)resumePath complete:(VPLDownloaderCompletionBlock)complete {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.downloaderQueue, ^{
        NSMutableArray *downloadFileList = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in fileList) {
            NSString *url = [dict objectForKey:@"url"];
            NSString *fileName = [url lastPathComponent];
            NSString *localPath = [resumePath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];

            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
#ifdef DEBUG
#else
                NSString *fileMD5 = [VPUPMD5Util md5File:localPath size:0];
                if (![[dict objectForKey:@"md5"] isEqualToString:fileMD5]) {
                    [downloadFileList addObject:dict];
                }
#endif
            }
            else {
                [downloadFileList addObject:dict];
            }
        }
        if (downloadFileList.count > 0) {
            VPLDownloaderObject *loaderObject = [VPLDownloaderObject objectWithFilesList:downloadFileList destinationPath:resumePath];
            [weakSelf downloadLFilesWithLoaderObject:loaderObject complete:complete];
        }
        else {
            [weakSelf callbackComplete:complete withError:nil];
        }
    });
}

- (void)downloadLFilesWithLoaderObject:(VPLDownloaderObject *)loaderObject complete:(VPLDownloaderCompletionBlock)complete {
    [self downloadLFilesWithLoaderObject:loaderObject complete:complete repeatCount:0];
}

- (void)downloadLFilesWithLoaderObject:(VPLDownloaderObject *)loaderObject complete:(VPLDownloaderCompletionBlock)complete repeatCount:(NSInteger)repeatCount {
    
    if (!loaderObject || !loaderObject.filesList || loaderObject.filesList.count == 0) {
        [self callbackComplete:complete withError:nil];
        return;
    }
    
    __block VPLDownloaderObject *blockObject = loaderObject;
    
    __weak typeof(self) weakSelf = self;
    
    [self.prefetchManager prefetchURLs:loaderObject.filesUrl
                             fileNames:loaderObject.filesName
                       destinationPath:loaderObject.tempFilePath
                       completionBlock:^(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls) {
                           if (numberOfSkippedUrls > 0) {
                               if (repeatCount == 0) {
                                   [self downloadLFilesWithLoaderObject:blockObject complete:complete repeatCount:1];
                               } else {
                                   NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3002 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file error, success count %ld, faild count %ld", numberOfFinishedUrls, numberOfSkippedUrls]}];
//                                   [weakSelf callbackComplete:complete withError:error];
                                   [weakSelf checkDownloadObject:blockObject complete:complete skippedCount:numberOfSkippedUrls];
                               }
                           }
                           else {
//                               [weakSelf checkDownloadFilesList:filesList complete:complete];
                               [weakSelf checkDownloadObject:blockObject complete:complete];
                           }
                       }];
}

- (void)checkDownloadObject:(VPLDownloaderObject *)loaderObject complete:(VPLDownloaderCompletionBlock)complete {
    [self checkDownloadObject:loaderObject complete:complete skippedCount:0];
}

- (void)checkDownloadObject:(VPLDownloaderObject *)loaderObject complete:(VPLDownloaderCompletionBlock)complete skippedCount:(NSInteger)skippedCount {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.downloaderQueue, ^{
        NSInteger failedCount = skippedCount;
        NSMutableArray *downloadFiles = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 0; i < loaderObject.filesList.count; i++) {
            NSString *fileName = [loaderObject.filesName objectAtIndex:i];
            NSString *fileUrl = [loaderObject.filesUrl objectAtIndex:i];
            NSString *localPath = [loaderObject.tempFilePath stringByAppendingPathComponent:fileName];
            [downloadFiles addObject:localPath];
            NSDictionary *dict = [loaderObject.filesList objectAtIndex:i];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                NSString *fileMD5 = [VPUPMD5Util md5File:localPath size:0];
                if (![[dict objectForKey:@"md5"] isEqualToString:fileMD5]) {
                    failedCount += 1;
                } else {
                    [loaderObject.statisticsList addFileTrafficByName:fileName fileUrl:fileUrl filePath:localPath];
                }
            }
        }
        
        if (failedCount == 0) {
            NSMutableArray *moveErrors = [NSMutableArray arrayWithCapacity:0];
            for (NSString *fileName in loaderObject.filesName) {
                NSError *removeError = nil;
                NSString *targetPath = [loaderObject.destinationPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                NSString *sourcePath = [loaderObject.tempFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:sourcePath]) {
                    //下载文件不存在，则删除
                    continue;
                }
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&removeError];
                }
                NSError *copyError = nil;
                [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:&copyError];
                if (removeError) {
                    [moveErrors addObject:removeError];
                }
                if (copyError) {
                    [moveErrors addObject:copyError];
                }
            }
            if (moveErrors.count > 0) {
                NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3003 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file copy to target path error"]}];
                [self callbackComplete:complete withError:error withStatistics:loaderObject.statisticsList];
            }
            else {
                [self callbackComplete:complete withError:nil withStatistics:loaderObject.statisticsList];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3004 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file data error"]}];
            [weakSelf callbackComplete:complete withError:error withStatistics:loaderObject.statisticsList];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:loaderObject.tempFilePath error:nil];
    });
}

/*
- (void)checkDownloadFilesList:(NSArray *)filesList complete:(VPLDownloaderCompletionBlock)complete {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.downloaderQueue, ^{
        NSInteger failedCount = 0;
        NSMutableArray *downloadFiles = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *filesName = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in filesList) {
            NSString *url = [dict objectForKey:@"url"];
            NSString *fileName = [url lastPathComponent];
            NSString *localPath = [self.tempFilePath stringByAppendingString:fileName];
            [filesName addObject:fileName];
            [downloadFiles addObject:localPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
                NSString *fileMD5 = [VPUPMD5Util md5File:localPath size:0];
                if (![[dict objectForKey:@"md5"] isEqualToString:fileMD5]) {
                    failedCount += 1;
                }
            }
        }
        if (failedCount == 0) {
            NSMutableArray *moveErrors = [NSMutableArray arrayWithCapacity:0];
            for (NSString *fileName in filesName) {
                NSError *removeError = nil;
                NSString *targetPath = [self.resumePath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                NSString *sourcePath = [self.tempFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&removeError];
                }
                NSError *copyError = nil;
                [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:targetPath error:&copyError];
                if (removeError) {
                    [moveErrors addObject:removeError];
                }
                if (copyError) {
                    [moveErrors addObject:copyError];
                }
            }
            if (moveErrors.count > 0) {
                NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3003 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file copy to target path error"]}];
                [self callbackComplete:complete withError:error];
            }
            else {
                [self callbackComplete:complete withError:nil];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-3004 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file data error"]}];
            [weakSelf callbackComplete:complete withError:error];
        }
        [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:nil];
    });
}
 */

- (void)callbackComplete:(VPLDownloaderCompletionBlock)complete withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (complete) {
            complete(error, nil);
        }
    });
}

- (void)callbackComplete:(VPLDownloaderCompletionBlock)complete withError:(NSError *)error withStatistics:(VPUPTrafficStatisticsList *)trafficList {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (complete) {
            complete(error, trafficList);
        }
    });
}

@end
