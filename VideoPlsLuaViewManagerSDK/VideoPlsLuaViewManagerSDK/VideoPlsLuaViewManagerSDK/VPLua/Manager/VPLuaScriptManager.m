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
#import "VPUPCommonInfo.h"
#import "VPUPRSAUtil.h"
#import "VPUPBase64Util.h"
#import "VPLuaSDK.h"

#import "VPUPAESUtil.h"
#import "VPUPPathUtil.h"
#import "VPUPMD5Util.h"
#import "VPUPPrefetchManager.h"
#import "VPLuaLoader.h"

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
        [self preloadLuaFilesWithUrl:url];
    }
    
    return self;
}

- (VPUPPrefetchManager *)prefetchManager {
    if (!_prefetchManager) {
        _prefetchManager = [[VPUPPrefetchManager alloc] init];
    }
    return _prefetchManager;
}

- (void)preloadLuaFilesWithUrl:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = url;
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSString *commonParamString = VPUP_DictionaryToJson(@{@"commonParam":[VPUPCommonInfo commonParam]});
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
        
        if ([[data objectForKey:@"resCode"] isEqualToString:@"00"] && [data objectForKey:@"luaList"] > 0) {
            NSArray *luaList = [data objectForKey:@"luaList"];
            if (luaList.count > 0) {
                [strongSelf downloadFilesList:luaList];
                return;
            }
        }
        
        // 无需下载，没有下载的文件
        [strongSelf downloadSuccess:YES];
    };
    [_apiManager sendAPIRequest:api];
}

- (void)downloadFilesList:(NSArray *)filesList {
    if (!filesList || filesList.count == 0) {
        [self downloadSuccess:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[VPLuaLoader sharedLoader] checkAndDownloadFilesList:filesList complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
        
        if (trafficList) {
            [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeInitApp];
        }
        
        if (error) {
            [weakSelf error:error type:VPLuaScriptManagerErrorTypeDownloadFile];
        }
        else {
            [weakSelf downloadSuccess:YES];
        }
    }];
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
