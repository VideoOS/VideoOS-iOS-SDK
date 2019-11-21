//
//  VPLuaDownloader.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPTrafficStatistics.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLuaDownloaderObject : NSObject

// [{url,md5},{url,md5},...]
@property (nonatomic) NSArray *filesList;
@property (nonatomic) NSMutableArray *filesUrl;
@property (nonatomic) NSMutableArray *filesName;
@property (nonatomic) NSString *destinationPath;
@property (nonatomic) NSString *tempFilePath;
@property (nonatomic) VPUPTrafficStatisticsList *statisticsList;

+ (instancetype)objectWithFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath;

@end

typedef void(^VPLuaDownloaderCompletionBlock)(NSError *error, VPUPTrafficStatisticsList *trafficList);

@interface VPLuaDownloader : NSObject

+ (instancetype)sharedDownloader;

//默认下载到luaOSPath
- (void)checkAndDownloadFilesList:(NSArray *)filesList complete:(VPLuaDownloaderCompletionBlock)complete;

- (void)checkAndDownloadFilesList:(NSArray *)filesList resumePath:(NSString *)resumePath complete:(VPLuaDownloaderCompletionBlock)complete;

- (void)checkFilesListWithLocal:(NSArray *)fileList resumePath:(NSString *)resumePath complete:(VPLuaDownloaderCompletionBlock)complete;

- (void)downloadLuaFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath complete:(VPLuaDownloaderCompletionBlock)complete;

//- (void)checkDownloadFilesList:(NSArray *)filesList complete:(VPLuaDownloaderCompletionBlock)complete;

- (void)checkDownloadObject:(VPLuaDownloaderObject *)loaderObject complete:(VPLuaDownloaderCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
