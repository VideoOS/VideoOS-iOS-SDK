//
//  VPLScriptManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2018/1/9.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPLScriptManager.h"
#import "VPUPResumeDownloader.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPJsonUtil.h"
#import <VPLuaViewSDK/LVZipArchive.h>
#import "VPUPCommonInfo.h"
#import "VPUPRSAUtil.h"
#import "VPUPBase64Util.h"
#import "VPLSDK.h"

#import "VPUPAESUtil.h"
#import "VPUPPathUtil.h"
#import "VPUPMD5Util.h"
#import "VPUPPrefetchManager.h"
#import "VPLDownloader.h"

NSString *const VPLScriptManagerErrorDomain = @"VPLScriptManager.Error";

@interface VPLScriptManager ()

@property (nonatomic ,copy) NSString *lPath;
@property (nonatomic, copy) NSString *versionFilePath;
@property (nonatomic, copy) NSString *nativeVersion;
@property (nonatomic, copy) NSString *versionData;
@property (nonatomic, copy) NSString *tempVersionFilePath;
@property (nonatomic, weak) id<VPUPHTTPAPIManager>apiManager;
@property (nonatomic, strong) VPUPPrefetchManager *prefetchManager;
@property (nonatomic, strong) dispatch_queue_t luaScriptQueue;

@end

@implementation VPLScriptManager

- (instancetype)initWithLuaStorePath:(NSString *)path
                          apiManager:(id<VPUPHTTPAPIManager>)apiManager
                          versionUrl:(NSString *)url
                       nativeVersion:(NSString *)nativeVersion {
    self = [super init];
    if (self) {
        
        _lPath = path;
        _versionFilePath = [path stringByAppendingPathComponent:@"version.json"];
        _nativeVersion = nativeVersion;
        _apiManager = apiManager;
        _luaScriptQueue = dispatch_queue_create("com.videopls.lua.scriptManager", DISPATCH_QUEUE_SERIAL);
        [self preloadLFileFilesWithUrl:url];
    }
    
    return self;
}

- (VPUPPrefetchManager *)prefetchManager {
    if (!_prefetchManager) {
        _prefetchManager = [[VPUPPrefetchManager alloc] init];
    }
    return _prefetchManager;
}

- (void)preloadLFileFilesWithUrl:(NSString *)url {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = url;
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSString *commonParamString = VPUP_DictionaryToJson(@{@"commonParam":[VPUPCommonInfo commonParam]});
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        if (!weakSelf) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            [strongSelf error:error type:VPLScriptManagerErrorTypeGetVersion];
            return;
        }
        
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret];
        strongSelf.versionData = dataString;
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        
        if ([[data objectForKey:@"resCode"] isEqualToString:@"00"] && [data objectForKey:@"miniAppInfoList"] > 0) {
            NSArray *miniAppInfoList = [data objectForKey:@"miniAppInfoList"];
            if (miniAppInfoList.count > 0) {
                [strongSelf downloadMiniAppInfoList:miniAppInfoList];
                return;
            }
        }
        
        // 无需下载，没有下载的文件
        [strongSelf downloadSuccess:YES];
    };
    [_apiManager sendAPIRequest:api];
}

- (void)downloadMiniAppInfoList:(NSArray *)miniAppInfoList {
    if (!miniAppInfoList || miniAppInfoList.count == 0) {
        [self downloadSuccess:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    for (NSDictionary *miniAppInfo in miniAppInfoList) {
        VPMiniAppInfo *appInfoObject = [VPMiniAppInfo initWithResponseDictionary:miniAppInfo];
        
        [[VPLDownloader sharedDownloader] checkAndDownloadFilesListWithAppInfo:appInfoObject complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
            
            if (trafficList) {
                [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeInitApp];
            }
            
            if (error) {
                [weakSelf error:error type:VPLScriptManagerErrorTypeDownloadFile];
            }
            else {
                [weakSelf downloadSuccess:YES];
            }
        }];
    }
}

- (void)downloadFilesList:(NSArray *)filesList {
    if (!filesList || filesList.count == 0) {
        [self downloadSuccess:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[VPLDownloader sharedDownloader] checkAndDownloadFilesList:filesList complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
        
        if (trafficList) {
            [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeInitApp];
        }
        
        if (error) {
            [weakSelf error:error type:VPLScriptManagerErrorTypeDownloadFile];
        }
        else {
            [weakSelf downloadSuccess:YES];
        }
    }];
}

#pragma mark - protocol used
- (void)error:(NSError *)error type:(VPLScriptManagerErrorType)type {
    
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
