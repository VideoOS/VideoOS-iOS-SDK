//
//  VPLServieAd.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLServiceAd.h"
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
#import "VPMiniAppInfo.h"

@interface VPLServiceAd()

@property (nonatomic, copy) VPLServiceCompletionBlock complete;
@property (nonatomic, strong) VPLServiceConfig *config;

@end

@implementation VPLServiceAd

- (void)startServiceWithConfig:(VPLServiceConfig *)config complete:(VPLServiceCompletionBlock)complete {
    self.config = config;
    self.complete = complete;
    [self requestServiceAd];
}

- (NSInteger)serviceTypeToAdsType:(VPLServiceType)type {
    NSInteger adsType = 0;
    switch (type) {
        case VPLServiceTypePreAdvertising:
            adsType = 3;
            break;
        case VPLServiceTypePostAdvertising:
            adsType = 4;
            break;
        case VPLServiceTypePauseAd:
            adsType = 5;
            break;
            
        default:
            adsType = 0;
            break;
    }
    return adsType;
}

- (void)requestServiceAd {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLServerHost, @"api/queryAllAds"];
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    [param setObject:self.config.identifier forKey:@"videoId"];
    [param setObject:@([self serviceTypeToAdsType:self.config.type]) forKey:@"adsType"];
    [param setObject:@(self.config.duration) forKey:@"duration"];
    
    NSString *paramString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:paramString key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!weakSelf) {
            return;
        }
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            if (!error) {
                error = [NSError errorWithDomain:VPLErrorDomain code:-4101 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"queryAllAds error"]}];
            }
            [strongSelf callbackComplete:strongSelf.complete withError:error];
            return;
        }
        
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        NSLog(@"VPLServiceAd %@", data);
        if (![data objectForKey:@"launchInfo"]) {
            NSError *error = [NSError errorWithDomain:VPLErrorDomain code:-4102 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"server do not have ad"]}];
            [strongSelf callbackComplete:strongSelf.complete withError:error];
        }
        else {
            strongSelf.serviceId = [[data objectForKey:@"launchInfo"] objectForKey:@"id"];
            [strongSelf downloadFileFromData:[data objectForKey:@"launchInfo"]];
//            [strongSelf runLuaWithData:[data objectForKey:@"launchInfo"]];
        }
    };
    [[VPLNetworkManager Manager].httpManager sendAPIRequest:api];
}

- (void)downloadFileFromData:(NSDictionary *)data {
    
    __weak typeof(self) weakSelf = self;
    NSDictionary *miniAppInfo = [data objectForKey:@"miniAppInfo"]; // [data objectForKey:@"luaList"];
    VPMiniAppInfo *appInfo = [VPMiniAppInfo initWithResponseDictionary:miniAppInfo];
     
    [[VPLDownloader sharedDownloader] checkAndDownloadFilesListWithAppInfo:appInfo complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
        
        if (trafficList) {
            [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
        }
        if (error) {
            [weakSelf callbackComplete:weakSelf.complete withError:error];
        }
        else {
            [weakSelf runLuaWithData:data];
        }
    }];
}

- (void)runLuaWithData:(NSDictionary *)data {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://topLuaView?template=%@&id=%@&priority=%ld&miniAppId=%@",
                                       VPUPRoutesSDKLView,
                                       [[data objectForKey:@"miniAppInfo"] objectForKey:@"template"],
                                       [data objectForKey:@"id"],
                                       VPLBaseNodeWedgePriority,
                                       [[data objectForKey:@"miniAppInfo"] objectForKey:@"miniAppId"]]];
    [VPUPRoutes routeURL:url withParameters:data completion:^(id  _Nonnull result) {
        
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
