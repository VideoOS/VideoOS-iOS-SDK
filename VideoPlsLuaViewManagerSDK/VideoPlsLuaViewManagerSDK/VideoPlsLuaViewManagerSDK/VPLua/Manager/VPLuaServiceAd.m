//
//  VPLuaServieAd.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaServiceAd.h"
#import "VPLuaCommonInfo.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPLuaNetworkManager.h"
#import "VPUPMD5Util.h"
#import "VPUPRandomUtil.h"
#import "VPUPUrlUtil.h"
#import "VPUPJsonUtil.h"
#import "VPUPAESUtil.h"
#import "VPLuaSDK.h"
#import "VPLuaLoader.h"
#import "VPUPRoutes.h"
#import "VPUPRoutesConstants.h"
#import "VPLuaConstant.h"

@interface VPLuaServiceAd()

@property (nonatomic, copy) VPLuaServiceCompletionBlock complete;
@property (nonatomic, strong) VPLuaServiceConfig *config;

@end

@implementation VPLuaServiceAd

- (void)startServiceWithConfig:(VPLuaServiceConfig *)config complete:(VPLuaServiceCompletionBlock)complete {
    self.config = config;
    self.complete = complete;
    [self requestServiceAd];
}

- (NSInteger)serviceTypeToAdsType:(VPLuaServiceType)type {
    NSInteger adsType = 0;
    switch (type) {
        case VPLuaServiceTypePreAdvertising:
            adsType = 3;
            break;
        case VPLuaServiceTypePostAdvertising:
            adsType = 4;
            break;
        case VPLuaServiceTypePauseAd:
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
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"api/queryAllAds"];
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[VPLuaCommonInfo commonParam] forKey:@"commonParam"];
    [param setObject:self.config.identifier forKey:@"videoId"];
    [param setObject:@([self serviceTypeToAdsType:self.config.type]) forKey:@"adsType"];
    [param setObject:@(self.config.duration) forKey:@"duration"];
    
    NSString *paramString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:paramString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!weakSelf) {
            return;
        }
        
        if (error || !responseObject || ![responseObject objectForKey:@"encryptData"]) {
            if (!error) {
                error = [NSError errorWithDomain:VPLuaErrorDomain code:-4101 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"queryAllAds error"]}];
            }
            [strongSelf callbackComplete:strongSelf.complete withError:error];
            return;
        }
        
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        NSLog(@"VPLuaServiceAd %@", data);
        if (![data objectForKey:@"launchInfo"]) {
            NSError *error = [NSError errorWithDomain:VPLuaErrorDomain code:-4102 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"server do not have ad"]}];
            [strongSelf callbackComplete:strongSelf.complete withError:error];
        }
        else {
            strongSelf.serviceId = [[data objectForKey:@"launchInfo"] objectForKey:@"id"];
            [strongSelf downloadFileFromData:[data objectForKey:@"launchInfo"]];
//            [strongSelf runLuaWithData:[data objectForKey:@"launchInfo"]];
        }
    };
    [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
}

- (void)downloadFileFromData:(NSDictionary *)data {
    NSArray *filesList = [data objectForKey:@"templates"];
    __weak typeof(self) weakSelf = self;
    [[VPLuaLoader sharedLoader] checkAndDownloadFilesList:filesList complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
        
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://defaultLuaView?template=%@&id=%@",VPUPRoutesSDKLuaView, [data objectForKey:@"template"], [data objectForKey:@"id"]]];
    [VPUPRoutes routeURL:url withParameters:data completion:^(id  _Nonnull result) {
        
    }];
}

- (void)callbackComplete:(VPLuaServiceCompletionBlock)complete withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (complete) {
            complete(error);
        }
    });
}

@end
