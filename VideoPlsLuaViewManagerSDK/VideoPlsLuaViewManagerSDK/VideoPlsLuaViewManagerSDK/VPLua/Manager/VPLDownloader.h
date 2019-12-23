//
//  VPLDownloader.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPTrafficStatistics.h"
#import "VPMiniAppInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLDownloaderObject : NSObject

// [{url,md5},{url,md5},...]
@property (nonatomic) NSArray *filesList;
@property (nonatomic) NSMutableArray *filesUrl;
@property (nonatomic) NSMutableArray *filesName;
@property (nonatomic) NSString *destinationPath;
@property (nonatomic) NSString *tempFilePath;
@property (nonatomic) VPUPTrafficStatisticsList *statisticsList;

+ (instancetype)objectWithFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath;

@end

typedef void(^VPLDownloaderCompletionBlock)(NSError *error, VPUPTrafficStatisticsList *trafficList);

@interface VPLDownloader : NSObject

+ (instancetype)sharedDownloader;

- (void)checkAndDownloadFilesListWithAppInfo:(VPMiniAppInfo *)appInfo complete:(VPLDownloaderCompletionBlock)complete;

//默认下载到lOSPath
- (void)checkAndDownloadFilesList:(NSArray *)filesList complete:(VPLDownloaderCompletionBlock)complete;

- (void)checkAndDownloadFilesList:(NSArray *)filesList resumePath:(NSString *)resumePath complete:(VPLDownloaderCompletionBlock)complete;

- (void)checkFilesListWithLocal:(NSArray *)fileList resumePath:(NSString *)resumePath complete:(VPLDownloaderCompletionBlock)complete;

- (void)downloadLFileFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath complete:(VPLDownloaderCompletionBlock)complete;

//- (void)checkDownloadFilesList:(NSArray *)filesList complete:(VPLDownloaderCompletionBlock)complete;

- (void)checkDownloadObject:(VPLDownloaderObject *)loaderObject complete:(VPLDownloaderCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
