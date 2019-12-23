//
//  DevLuaLoader.h
//  VPInterfaceControllerDemo
//
//  Created by videopls on 2019/10/23.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoOS/VideoPlsUtilsPlatformSDK/VPUPTrafficStatistics.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevLuaLoaderObject : NSObject

// [{url,md5},{url,md5},...]
@property (nonatomic) NSArray *filesList;
@property (nonatomic) NSMutableArray *filesUrl;
@property (nonatomic) NSMutableArray *filesName;
@property (nonatomic) NSString *destinationPath;
@property (nonatomic) NSString *tempFilePath;
@property (nonatomic) VPUPTrafficStatisticsList *statisticsList;

+ (instancetype)objectWithFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath;

@end

typedef void(^DevLuaLoaderCompletionBlock)(NSError *error, VPUPTrafficStatisticsList *trafficList);

@interface DevLuaLoader : NSObject

+ (instancetype)sharedLoader;

//默认下载到lOSPath
- (void)checkAndDownloadFilesList:(NSArray *)filesList complete:(DevLuaLoaderCompletionBlock)complete;

- (void)checkAndDownloadFilesList:(NSArray *)filesList resumePath:(NSString *)resumePath complete:(DevLuaLoaderCompletionBlock)complete;

- (void)checkFilesListWithLocal:(NSArray *)fileList resumePath:(NSString *)resumePath complete:(DevLuaLoaderCompletionBlock)complete;

//- (void)downloadLuaFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath complete:(DevLuaLoaderCompletionBlock)complete;

//- (void)checkDownloadFilesList:(NSArray *)filesList complete:(DevLuaLoaderCompletionBlock)complete;

- (void)checkDownloadObject:(DevLuaLoaderObject *)loaderObject complete:(DevLuaLoaderCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END

