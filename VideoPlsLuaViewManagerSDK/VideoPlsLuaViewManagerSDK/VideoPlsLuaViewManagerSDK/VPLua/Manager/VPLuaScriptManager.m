//
//  VPLuaScriptManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPLuaScriptManager.h"
#import "VPUPResumeDownloader.h"
#import "VPUPHTTPGeneralAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPJsonUtil.h"
#import <VPLuaViewSDK/LVZipArchive.h>
#import "VPLuaCommonInfo.h"
#import "VPUPRSAUtil.h"
#import "VPUPBase64Util.h"
#import "VPLuaSDK.h"
#import "VPUPAESUtil.h"

@interface VPLuaScriptManager ()

@property (nonatomic ,copy) NSString *luaPath;
@property (nonatomic, copy) NSString *versionFilePath;
@property (nonatomic, copy) NSString *nativeVersion;
@property (nonatomic, weak) id<VPUPHTTPAPIManager>apiManager;

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
        [self getLuaVersionInfoWithVersionUrl:url];
    }
    
    return self;
}

- (void)getLuaVersionInfoWithVersionUrl:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPGeneralAPI *api = [[VPUPHTTPGeneralAPI alloc] init];
    if ([VPLuaSDK sharedSDK].appKey && [VPLuaSDK sharedSDK].appKey.length > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:0];
        [headers addEntriesFromDictionary:api.apiRequestHTTPHeaderField];
        [headers setObject:[VPLuaSDK sharedSDK].appKey forKey:@"appKey"];
        api.apiRequestHTTPHeaderField = headers;
    }
    api.baseUrl = url;
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSString *commonParamString = VPUP_DictionaryToJson(@{@"commonParam":[VPLuaCommonInfo commonParam]});
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            [weakSelf error:error type:VPLuaScriptManagerErrorTypeGetVersion];
            return;
        }
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        if (weakSelf.nativeVersion && [data objectForKey:weakSelf.nativeVersion]) {
            data = [data objectForKey:weakSelf.nativeVersion];
        }
        NSString *url = [data objectForKey:@"downloadUrl"];
        if (!url || [url isEqual:[NSNull null]]) {
            [weakSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
            return;
        }
        
        NSString *version = [data objectForKey:@"version"];
        NSString *versionFileString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:weakSelf.versionFilePath] encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *versionFile = VPUP_JsonToDictionary(versionFileString);
        NSString *localVersion = [versionFile objectForKey:@"version"];
        
        if (!localVersion || ![localVersion isEqualToString:version]) {
            //下载并删除之前下载的所有文件
            //[weakSelf removeAllFileAtLuaPath];
            [weakSelf downloadWithFileUrl:data];
            return;
        }
        // 无需下载，本地已经是最新版本
        [weakSelf downloadSuccess:YES];
    };
    [_apiManager sendAPIRequest:api];
}

- (void)downloadWithFileUrl:(NSDictionary *)data {
    __weak typeof(self) weakSelf = self;
    NSString *url = [data objectForKey:@"downloadUrl"];
    VPUPResumeDownloader *downloader = [[VPUPResumeDownloader alloc] initWithDownloadUrl:url resumePath:_luaPath progress:nil completionHandler:^(VPUPResumeDownloader *downloader, NSURL *filePath, NSError *error) {
        if (error) {
            [weakSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
            return;
        }
        [weakSelf unzipWithFilePath:filePath.relativePath data:data];
    }];
    [downloader resume];
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
