//
//  VPLTrackManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/14.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLTrackManager.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPLNetworkManager.h"
#import "VPLSDK.h"
#import "VPUPCommonInfo.h"
#import "VPUPJsonUtil.h"
#import "VPUPAESUtil.h"
#import "VPUPReport.h"

@implementation VPLTrackManager

+ (void)trackVideoModeSwitch:(BOOL)isOpen {
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    __weak typeof(api) weakApi = api;
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLServerHost, @"statistic/collectVisionSwitchTimes/v2"];
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    [param setObject:[VPLSDK sharedSDK].appKey forKey:@"appKey"];
    [param setObject: isOpen ? @"1" : @"0" forKey:@"onOrOff"];
    
    NSString *paramString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:paramString key:[VPLSDK sharedSDK].appSecret initVector:[VPLSDK sharedSDK].appSecret]};
    
    //track do not handle completion
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        if (error) {
            [VPUPReport addHTTPErrorReportByReportClass:[weakSelf class] error:error api:weakApi];
        }
    };
    [[VPLNetworkManager Manager].httpManager sendAPIRequest:api];
}

@end
