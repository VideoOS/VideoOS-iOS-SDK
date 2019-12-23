//
//  VPLServiceVideoMode.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLServiceVideoMode.h"
#import "VPUPCommonInfo.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPLNetworkManager.h"
#import "VPUPMD5Util.h"
#import "VPUPRandomUtil.h"
#import "VPUPUrlUtil.h"
#import "VPUPJsonUtil.h"
#import "VPUPAESUtil.h"
#import "VPLSDK.h"
#import "VPLDownloader.h"
#import "VPUPRoutes.h"
#import "VPUPRoutesConstants.h"
#import "VPLConstant.h"
#import "VPUPPathUtil.h"
#import <VPLuaViewSDK/LVZipArchive.h>

@interface VPLServiceVideoMode()

@property (nonatomic, copy) VPLServiceCompletionBlock complete;
@property (nonatomic, strong) VPLServiceConfig *config;
@property (nonatomic, strong) NSError *lFileError;
@property (nonatomic, strong) NSError *jsonFileError;
@property (nonatomic, strong) NSMutableDictionary *videoModeData;
@property (nonatomic, strong) NSDictionary *configData;
@property (nonatomic, strong) dispatch_queue_t videoModeQueue;
@property (nonatomic, copy) NSString *resumeDataPath;

@end

@implementation VPLServiceVideoMode

- (void)startServiceWithConfig:(VPLServiceConfig *)config complete:(VPLServiceCompletionBlock)complete {
    self.config = config;
    self.complete = complete;
    self.resumeDataPath = [VPUPPathUtil subPathOfVideoMode:[VPUPMD5Util md5HashString:self.videoId]];
    self.videoModeQueue = dispatch_queue_create("VPL_Service_Video_Mode", DISPATCH_QUEUE_SERIAL);
    [self requestServiceData];
}
- (void)requestServiceData {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLServerHost, @"vision/v2/getLabelConf"];
//    api.baseUrl =  @"http://mock.videojj.com/mock/5b029ad88e21c409b29a2114/api/getLabelConf#!method=POST&queryParameters=%5B%5D&body=&headers=%5B%5D";
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    [param setObject:self.config.identifier forKey:@"videoId"];
    
    NSString *paramString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:paramString key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!weakSelf) {
            return;
        }
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            if (!error) {
                error = [NSError errorWithDomain:VPLErrorDomain code:-4201 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"getLabelConf error"]}];
            }
            [strongSelf callbackComplete:strongSelf.complete withError:error];
            return;
        }
        
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        
//        data = [NSMutableDictionary dictionaryWithCapacity:0];
//        NSDictionary *luaDict = @{@"url":@"https://m.videojj.com/os/lua/os_video_mode_hotspot.lua",
//                                  @"md5":@"07c9c8e2f60183c21848f346bb7afd16"};
//
//        NSArray *luaList = @[luaDict];
//
//        [data setValue:luaList forKey:@"luaList"];
//
//        NSDictionary *jsonDict = @{@"url":@"https://m.videojj.com/os/lua/SuccessorPlan07.zip",
//                                  @"md5":@"7194fd1a5e0a2b60332f9ca4aecb2121"};
//
//        NSArray *jsonList = @[jsonDict];
//
//        [data setValue:jsonList forKey:@"jsonList"];
//
//        [data setValue:@"os_video_mode_hotspot.lua" forKey:@"template"];
//
//        [data setValue:@"00" forKey:@"resCode"];
//
//        [data setValue:@"message" forKey:@"resMsg"];
//        
//        NSString *paramString = VPUP_DictionaryToJson(data);
//        NSDictionary *mock = @{@"encryptData":[VPUPAESUtil aesEncryptString:paramString key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret]};
//        NSLog(@"%@", mock);
        
        if (![[data objectForKey:@"resCode"] isEqualToString:@"00"]) {
            NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-4202 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"server do not have data"]}];
            [strongSelf callbackComplete:strongSelf.complete withError:error];
        }
        else {
//            [strongSelf runLuaWithData:data];
            strongSelf.serviceId = [VPUPMD5Util md5HashString:dataString];
            strongSelf.configData = data;
            [strongSelf downloadFileFromData:data];
        }
    };
    [[VPLNetworkManager Manager].httpManager sendAPIRequest:api];
}

- (void)downloadFileFromData:(NSDictionary *)data {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.videoModeQueue, ^{
        
        dispatch_group_t batch_api_group = dispatch_group_create();
        
        NSDictionary *bubbleMiniAppInfo = [data objectForKey:@"desktopMiniAppInfo"]; // [data objectForKey:@"luaList"];
        VPMiniAppInfo *bubbleAppInfo = [VPMiniAppInfo initWithResponseDictionary:bubbleMiniAppInfo];
        
        dispatch_group_enter(batch_api_group);
        [[VPLDownloader sharedDownloader] checkAndDownloadFilesListWithAppInfo:bubbleAppInfo complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
            
            if (trafficList) {
                [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
            }
            
            if (error) {
                [weakSelf callbackComplete:weakSelf.complete withError:error];
                weakSelf.lFileError = error;
            }
            dispatch_group_leave(batch_api_group);
        }];
        
        NSDictionary *videoModeMiniAppInfo = [data objectForKey:@"videoModeMiniAppInfo"]; // [data objectForKey:@"luaList"];
        VPMiniAppInfo *videoModeAppInfo = [VPMiniAppInfo initWithResponseDictionary:videoModeMiniAppInfo];
        
        dispatch_group_enter(batch_api_group);
        [[VPLDownloader sharedDownloader] checkAndDownloadFilesListWithAppInfo:videoModeAppInfo complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
            
            if (trafficList) {
                [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
            }
            
            if (error) {
                [weakSelf callbackComplete:weakSelf.complete withError:error];
                weakSelf.lFileError = error;
            }
            dispatch_group_leave(batch_api_group);
        }];
        
        NSArray *jsonList = [data objectForKey:@"jsonList"];
        if (jsonList && jsonList.count > 0) {
            dispatch_group_enter(batch_api_group);
            [[VPLDownloader sharedDownloader] checkAndDownloadFilesList:jsonList resumePath:self.resumeDataPath complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
                
                if (trafficList) {
                    [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
                }
                
                if (error) {
                    [weakSelf callbackComplete:weakSelf.complete withError:error];
                    weakSelf.jsonFileError = error;
                }
                else {
                    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *fileDict in jsonList) {
                        NSString *url = [fileDict objectForKey:@"url"];
                        NSString *filename = [url lastPathComponent];
                        NSString *path = [NSString stringWithFormat:@"%@/%@", self.resumeDataPath, filename];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                            LVZipArchive *archive = [LVZipArchive archiveWithData:[NSData dataWithContentsOfFile:path]];
                            
                            if (![archive unzipToDirectory:self.resumeDataPath]) {
                                NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-4203 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"unzip file error"]}];
                                [weakSelf callbackComplete:weakSelf.complete withError:error];
                                self.jsonFileError = error;
                                dispatch_group_leave(batch_api_group);
                                return;
                            }
                        }
                    }
                    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.resumeDataPath error:nil];
                    for (NSString *filename in array) {
                        if (![[filename lastPathComponent] containsString:@".zip"]) {
                            NSData *fileData = [[NSData alloc] initWithContentsOfFile:[self.resumeDataPath stringByAppendingPathComponent:filename]];
                            if (fileData) {
                                NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableContainers error:nil];
                                if (dataDict && dataDict.count > 0) {
                                    [dataArray addObject:dataDict];
                                }
                            }
                        }
                    }
                    if (dataArray.count > 0) {
                        weakSelf.videoModeData = [NSMutableDictionary dictionary];
                        [weakSelf.videoModeData setObject:dataArray forKey:@"data"];
                    }
                    else {
                        weakSelf.videoModeData = nil;
                        error = [NSError errorWithDomain:VPLErrorDomain code:-4204 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"local get data error"]}];
                        [weakSelf callbackComplete:weakSelf.complete withError:error];
                        weakSelf.jsonFileError = error;
                    }
                }
                dispatch_group_leave(batch_api_group);
            }];
        }
        else {
            self.jsonFileError = nil;
        }
        
        dispatch_group_notify(batch_api_group, dispatch_get_main_queue(), ^{
            if (!weakSelf.lFileError && !weakSelf.jsonFileError) {
                
                [weakSelf runLuaWithData:weakSelf.videoModeData];
            }
            else {
                weakSelf.lFileError = nil;
                weakSelf.jsonFileError = nil;
            }
        });
        
    });
}

- (void)unzipJsonFile:(NSArray *)jsonList {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(self.videoModeQueue, ^{
    
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *fileDict in jsonList) {
            NSString *url = [fileDict objectForKey:@"url"];
            NSString *filename = [url lastPathComponent];
            NSString *path = [NSString stringWithFormat:@"%@/%@", [VPUPPathUtil lOSPath], filename];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                LVZipArchive *archive = [LVZipArchive archiveWithData:[NSData dataWithContentsOfFile:path]];
                
                NSString *unzipPath = [VPUPPathUtil subPathOfLua:weakSelf.serviceId];
                if ([archive unzipToDirectory:unzipPath]) {
                    NSString *dataFilename = [filename substringToIndex:filename.length - 4];
                    NSString *dataPath = [NSString stringWithFormat:@"%@/%@", [VPUPPathUtil lPath], dataFilename];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
                        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:dataPath] options:NSJSONReadingMutableContainers error:nil];
                        if (dataDict && dataDict.count > 0) {
                            [dataArray addObject:dataDict];
                        }
                    }
                }
            }
        }
        if (dataArray.count == jsonList.count) {
            weakSelf.videoModeData = [NSMutableDictionary dictionary];
            [weakSelf.videoModeData setObject:dataArray forKey:@"data"];
        }
        else {
            weakSelf.videoModeData = nil;
            NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-4202 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"local get data error"]}];
            [weakSelf callbackComplete:weakSelf.complete withError:error];
        }

    });
}


- (void)runLuaWithData:(NSMutableDictionary *)data {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict addEntriesFromDictionary:self.configData];
    [dict addEntriesFromDictionary:data];
    [dict setObject:self.serviceId forKey:@"id"];
    [dict setObject:@(self.config.videoModeType) forKey:@"videoModeType"];
    [data setObject:@(self.config.videoModeType) forKey:@"videoModeType"];
    if ([data objectForKey:@"data"]) {
        [data setObject:[self.configData objectForKey:@"videoModeMiniAppInfo"] forKey:@"miniAppInfo"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://defaultLuaView?template=%@&id=%@&miniAppId=%@",
                                           VPUPRoutesSDKLView,
                                           [[dict objectForKey:@"videoModeMiniAppInfo"] objectForKey:@"template"],
                                           [dict objectForKey:@"id"],
                                           [[dict objectForKey:@"videoModeMiniAppInfo"] objectForKey:@"miniAppId"]]];
        [VPUPRoutes routeURL:url withParameters:data completion:^(id  _Nonnull result) {
            
        }];
    }
    
    if (!data) {
        data = [NSMutableDictionary dictionary];
    }
    [data setObject:[self.configData objectForKey:@"desktopMiniAppInfo"] forKey:@"miniAppInfo"];
    if (self.config.eyeOriginPoint.x > 0 || self.config.eyeOriginPoint.y > 0) {
        [data setValue:@(self.config.eyeOriginPoint.x) forKey:@"eyeOriginPointX"];
        [data setValue:@(self.config.eyeOriginPoint.y) forKey:@"eyeOriginPointY"];
    }
    if (self.configData) {
        [data setValue:self.configData forKey:@"labelConfData"];
    }
    
    NSURL *bubbleUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://desktopLuaView?template=%@&id=%@&miniAppId=%@",
                                              VPUPRoutesSDKLView,
                                              [[dict objectForKey:@"desktopMiniAppInfo"] objectForKey:@"template"],
                                              [dict objectForKey:@"id"],
                                              [[dict objectForKey:@"desktopMiniAppInfo"] objectForKey:@"miniAppId"]]];
    [VPUPRoutes routeURL:bubbleUrl withParameters:data completion:^(id  _Nonnull result) {
        
    }];
}

- (void)callbackComplete:(VPLServiceCompletionBlock)complete withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (complete) {
            complete(error);
        }
    });
}

@end
