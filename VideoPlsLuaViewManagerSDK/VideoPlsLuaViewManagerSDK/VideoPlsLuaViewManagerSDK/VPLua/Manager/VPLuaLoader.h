//
//  VPLuaLoader.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/22.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPTrafficStatistics.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLuaLoaderObject : NSObject

// [{url,md5},{url,md5},...]
@property (nonatomic) NSArray *filesList;
@property (nonatomic) NSMutableArray *filesUrl;
@property (nonatomic) NSMutableArray *filesName;
@property (nonatomic) NSString *destinationPath;
@property (nonatomic) NSString *tempFilePath;
@property (nonatomic) VPUPTrafficStatisticsList *statisticsList;

+ (instancetype)objectWithFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath;

@end

typedef void(^VPLuaLoaderCompletionBlock)(NSError *error, VPUPTrafficStatisticsList *trafficList);

@interface VPLuaLoader : NSObject

+ (instancetype)sharedLoader;

//默认下载到luaOSPath
- (void)checkAndDownloadFilesList:(NSArray *)filesList complete:(VPLuaLoaderCompletionBlock)complete;

- (void)checkAndDownloadFilesList:(NSArray *)filesList resumePath:(NSString *)resumePath complete:(VPLuaLoaderCompletionBlock)complete;

- (void)checkFilesListWithLocal:(NSArray *)fileList resumePath:(NSString *)resumePath complete:(VPLuaLoaderCompletionBlock)complete;

- (void)downloadLuaFilesList:(NSArray *)filesList destinationPath:(NSString *)destinationPath complete:(VPLuaLoaderCompletionBlock)complete;

//- (void)checkDownloadFilesList:(NSArray *)filesList complete:(VPLuaLoaderCompletionBlock)complete;

- (void)checkDownloadObject:(VPLuaLoaderObject *)loaderObject complete:(VPLuaLoaderCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
