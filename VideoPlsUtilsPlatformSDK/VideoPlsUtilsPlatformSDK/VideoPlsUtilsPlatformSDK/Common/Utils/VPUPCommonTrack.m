//
//  VPUPCommonTrack.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/11/7.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPCommonTrack.h"
#import "VPUPHTTPNetworking.h"
#import "VPUPCommonInfo.h"
#import "VPUPJsonUtil.h"
#import "VPUPGeneralInfo.h"
#import "VPUPEncryption.h"
#import "VPUPReport.h"

static VPUPCommonTrack *shared = nil;

@interface VPUPCommonTrack()

@property (nonatomic) id<VPUPHTTPAPIManager> httpManager;

@end

@implementation VPUPCommonTrack

+ (VPUPCommonTrack *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared.httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
    });
    return shared;
}

- (void)sendTrackWithType:(VPUPCommonTrackType)trackType dataDict:(NSDictionary *)dict {
    
    //每个track都应该有统计数据
    if (dict == nil) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    __weak typeof(api) weakApi = api;
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", @"https://os-saas.videojj.com/os-api-saas", @"commonStats"];
    
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(trackType) forKey:@"type"];
    [param setObject:dict forKey:@"data"];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    
    NSString *commonParamString = VPUP_DictionaryToJson(param);
    NSString *secret = [VPUPGeneralInfo mainVPSDKAppSecret];
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:secret initVector:secret]};
    api.apiCompletionHandler = ^(id _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        if (error) {
            [VPUPReport addHTTPErrorReportByReportClass:[weakSelf class] error:error api:weakApi];
        }
    };
    
    [_httpManager sendAPIRequest:api];
}


@end
