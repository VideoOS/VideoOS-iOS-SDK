//
//  VPLuaScriptManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPLuaScriptManager.h"
#import "VPUPResumeDownloader.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPJsonUtil.h"
#import <VPLuaViewSDK/LVZipArchive.h>
#import "VPLuaCommonInfo.h"
#import "VPUPRSAUtil.h"
#import "VPUPBase64Util.h"
#import "VPLuaSDK.h"

#import "VPUPAESUtil.h"
#import "VPUPPathUtil.h"
#import "VPUPMD5Util.h"
#import "VPUPPrefetchManager.h"

NSString *const VPLuaScriptManagerErrorDomain = @"VPLuaScriptManager.Error";

@interface VPLuaScriptManager ()

@property (nonatomic ,copy) NSString *luaPath;
@property (nonatomic, copy) NSString *versionFilePath;
@property (nonatomic, copy) NSString *nativeVersion;
@property (nonatomic, copy) NSString *versionData;
@property (nonatomic, copy) NSString *tempVersionFilePath;
@property (nonatomic, weak) id<VPUPHTTPAPIManager>apiManager;
@property (nonatomic, strong) VPUPPrefetchManager *prefetchManager;
@property (nonatomic, strong) dispatch_queue_t luaScriptQueue;

@end

@implementation VPLuaScriptManager

- (instancetype)initWithLuaStorePath:(NSString *)path
                          apiManager:(id<VPUPHTTPAPIManager>)apiManager
                          versionUrl:(NSString *)url
                       nativeVersion:(NSString *)nativeVersion {
    self = [super init];
    if (self) {
        
        _luaPath = path;
        _versionFilePath = [path stringByAppendingPathComponent:@"version.json"];
        _nativeVersion = nativeVersion;
        _apiManager = apiManager;
        _luaScriptQueue = dispatch_queue_create("com.videopls.lua.scriptManager", DISPATCH_QUEUE_SERIAL);
        [self getLuaVersionInfoWithVersionUrl:url];
    }
    
    return self;
}

- (VPUPPrefetchManager *)prefetchManager {
    if (!_prefetchManager) {
        _prefetchManager = [[VPUPPrefetchManager alloc] init];
    }
    return _prefetchManager;
}

- (void)getLuaVersionInfoWithVersionUrl:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = url;
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSString *commonParamString = VPUP_DictionaryToJson(@{@"commonParam":[VPLuaCommonInfo commonParam]});
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        if (!weakSelf) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            [strongSelf error:error type:VPLuaScriptManagerErrorTypeGetVersion];
            return;
        }
        
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
        strongSelf.versionData = dataString;
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        
        NSString *version = [data objectForKey:@"version"];
        NSString *versionFileString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:strongSelf.versionFilePath] encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *versionFile = VPUP_JsonToDictionary(versionFileString);
        NSString *localVersion = [versionFile objectForKey:@"version"];
        
        if (!localVersion || ![localVersion isEqualToString:version]) {
            
            NSString *url = [data objectForKey:@"downloadUrl"];
            if (!url || [url isEqual:[NSNull null]]) {
                [strongSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
                return;
            }
            
            //下载并删除之前下载的所有文件
            //[weakSelf removeAllFileAtLuaPath];
            [strongSelf downloadWithFileUrl:data];
            return;
        }
        // 无需下载，本地已经是最新版本
        [strongSelf downloadSuccess:YES];
    };
    [_apiManager sendAPIRequest:api];
}

- (void)downloadWithFileUrl:(NSDictionary *)data {
    __weak typeof(self) weakSelf = self;
    NSString *url = [data objectForKey:@"downloadUrl"];
    self.tempVersionFilePath = [VPUPPathUtil subPathOfLua:[NSString stringWithFormat:@"/%@-template",[data objectForKey:@"version"]]];
    
    VPUPResumeDownloader *downloader = [[VPUPResumeDownloader alloc] initWithDownloadUrl:url resumePath:self.tempVersionFilePath progress:nil completionHandler:^(VPUPResumeDownloader *downloader, NSURL *filePath, NSError *error) {
        if (error) {
            [weakSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
            return;
        }
//        [weakSelf unzipWithFilePath:filePath.relativePath data:data];
        NSString *fileMD5 = [VPUPMD5Util md5File:[filePath path] size:0];
        if ([fileMD5 isEqualToString:[data objectForKey:@"fileMd5"]]) {
            [weakSelf checkFilesChange];
        }
        else {
            error = [NSError errorWithDomain:VPLuaScriptManagerErrorDomain code:-3001 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"filePath:%@, file:%@, download file md5 error", filePath, data]}];
            [weakSelf error:error type:VPLuaScriptManagerErrorTypFileMD5];
        }
    }];
    [downloader resume];
}

- (void)checkFilesChange {
    dispatch_async(_luaScriptQueue, ^{
        
        NSString *localFilesPath = [self.luaPath stringByAppendingPathComponent:@"manifest.json"];
        NSString *localFilesString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:localFilesPath] encoding:NSUTF8StringEncoding error:nil];
        //    NSDictionary *localFiles = VPUP_JsonToDictionary(localFilesString);
        //    NSArray *localFilesList = [localFiles objectForKey:@"data"];
        NSArray *localFilesList = (NSArray *)VPUP_JsonToDictionary(localFilesString);
        
        NSString *downloadFilesPath = [self.tempVersionFilePath stringByAppendingPathComponent:@"manifest.json"];
        NSString *downloadFilesString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:downloadFilesPath] encoding:NSUTF8StringEncoding error:nil];
        NSArray *downloadFilesList = (NSArray *)VPUP_JsonToDictionary(downloadFilesString);
        //    NSDictionary *downloadFiles = VPUP_JsonToDictionary(downloadFilesString);
        //    NSArray *downloadFilesList = [downloadFiles objectForKey:@"data"];
        
        NSMutableArray *needDownloadFilesList = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *downloadFile in downloadFilesList) {
            BOOL needDownload = YES;
            for (NSDictionary *localFile in localFilesList) {
                if ([[downloadFile objectForKey:@"name"] isEqualToString:[localFile objectForKey:@"name"]] && [[downloadFile objectForKey:@"md5"] isEqualToString:[localFile objectForKey:@"md5"]]) {
                    needDownload = NO;
                    break;
                }
            }
            if (needDownload) {
                [needDownloadFilesList addObject:downloadFile];
            }
        }
        if (needDownloadFilesList.count > 0) {
            [self downloadFilesList:needDownloadFilesList];
        }
        else {
            [self downloadSuccess:YES];
        }
    });
}

- (void)downloadFilesList:(NSArray *)filesList {
    if (!filesList || filesList.count == 0) {
        [self downloadSuccess:YES];
        return;
    }
    NSMutableArray *filesUrl = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *filesName = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *file in filesList) {
        [filesUrl addObject:[file objectForKey:@"url"]];
        [filesName addObject:[file objectForKey:@"name"]];
    }
    static NSInteger count = 0;
    __weak typeof(self) weakSelf = self;
    
    [self.prefetchManager prefetchURLs:filesUrl
                             fileNames:filesName
                       destinationPath:self.tempVersionFilePath
                       completionBlock:^(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls) {
                           if (numberOfSkippedUrls > 0) {
                               if (count < 3) {
                                   [weakSelf downloadFilesList:filesList];
                               }
                               else {
                                   count = 0;
                                   NSError *error = [NSError errorWithDomain:VPLuaScriptManagerErrorDomain code:-3002 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Download file error, success count %ld, faild count %ld", numberOfFinishedUrls, numberOfSkippedUrls]}];
                                   [weakSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
                               }
                           }
                           else {
                               count = 0;
                               [weakSelf checkDownLoadFiles:filesList];
                           }
                       }];
    count ++;
}

- (void)checkDownLoadFiles:(NSArray *)filesList {
    dispatch_async(_luaScriptQueue, ^{
        if (!filesList || filesList.count == 0) {
            [self downloadSuccess:YES];
            return;
        }
        
        NSError *error = nil;
        for (NSDictionary *file in filesList) {
            NSString *filePath = [self.tempVersionFilePath stringByAppendingPathComponent:[file objectForKey:@"name"]];
            NSString *fileMD5 = [VPUPMD5Util md5File:filePath size:0];
            if (![fileMD5 isEqualToString:[file objectForKey:@"md5"]]) {
                error = [NSError errorWithDomain:VPLuaScriptManagerErrorDomain code:-3003 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"filePath:%@, file:%@, download file md5 error", filePath, file]}];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        
        if (error) {
            [self error:error type:VPLuaScriptManagerErrorTypFileMD5];
        }
        else {
            [self copyFileFromPath:self.tempVersionFilePath toPath:self.luaPath];
            // 将版本写入文件，若失败删除
            NSError *writeError = nil;
            [self.versionData writeToFile:self.versionFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
            if (writeError) {
                [self removeAllFileAtLuaPath];
                [self error:writeError type:VPLuaScriptManagerErrorTypeWriteVersionFile];
                return;
            }
            // 最终完成
            [self downloadSuccess:YES];
            [[NSFileManager defaultManager] removeItemAtPath:self.tempVersionFilePath error:nil];
        }
    });
}

- (void)unzipWithFilePath:(NSString *)path data:(NSDictionary *)data {
    LVZipArchive *archive = [LVZipArchive archiveWithData:[NSData dataWithContentsOfFile:path]];
    if ([archive unzipToDirectory:self.luaPath]) {
        NSString *luaZipFilesPath = [self.luaPath stringByAppendingString:[NSString stringWithFormat:@"/%@-template",[data objectForKey:@"version"]]];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray* array = [fileManager contentsOfDirectoryAtPath:luaZipFilesPath error:nil];
        for(int i = 0; i<[array count]; i++) {
        
            NSString *fullPath = [luaZipFilesPath stringByAppendingPathComponent:[array objectAtIndex:i]];
            if ([[fullPath lastPathComponent] containsString:@"zip"]) {
                LVZipArchive *archive = [LVZipArchive archiveWithData:[NSData dataWithContentsOfFile:fullPath]];
                [archive unzipToDirectory:luaZipFilesPath];
            }
        }
        
        [self copyFileFromPath:luaZipFilesPath toPath:self.luaPath];
        NSString *jsonData = VPUP_DictionaryToJson(data);
        // 将版本写入文件，若失败删除
        NSError *writeError = nil;
        [jsonData writeToFile:self.versionFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
        if (writeError) {
            [self removeAllFileAtLuaPath];
            [self error:writeError type:VPLuaScriptManagerErrorTypeWriteVersionFile];
            return;
        }
        // 最终完成
        [self downloadSuccess:YES];
        [fileManager removeItemAtPath:luaZipFilesPath error:nil];
    }
    else {
        [self error:nil type:VPLuaScriptManagerErrorTypeUnzip];
    }
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)toPath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:sourcePath error:nil];
    
    for(int i = 0; i<[array count]; i++) {
        
        NSString *fullPath = [sourcePath stringByAppendingPathComponent:[array objectAtIndex:i]];
        NSString *fullToPath = [toPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        if ([fileManager fileExistsAtPath:fullToPath]) {
            [fileManager removeItemAtPath:fullToPath error:nil];
        }
        
        //判断是不是文件夹
        BOOL isFolder = NO;
        
        //判断是不是存在路径 并且是不是文件夹
        BOOL isExist = [fileManager fileExistsAtPath:fullPath isDirectory:&isFolder];
        if (isExist) {
            NSError *err = nil;
            [[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:fullToPath error:&err];
            NSLog(@"%@",err);
            if (isFolder) {
                [self copyFileFromPath:fullPath toPath:fullToPath];
            }
        }
    }
}

- (void)removeAllFileAtLuaPath {
    NSArray *paths = [[NSFileManager defaultManager] subpathsAtPath:_luaPath];
    for (NSString *path in paths) {
        NSString *filePath = [_luaPath stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - protocol used
- (void)error:(NSError *)error type:(VPLuaScriptManagerErrorType)type {
    
    if ([self.delegate respondsToSelector:@selector(scriptManager:error:errorType:)]) {
        [self.delegate scriptManager:self error:error errorType:type];
    }
    [self downloadSuccess:NO];
}

- (void)downloadSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scriptManager:downloadSuccessed:)]) {
            [self.delegate scriptManager:self downloadSuccessed:success];
        }
    });
}


@end
