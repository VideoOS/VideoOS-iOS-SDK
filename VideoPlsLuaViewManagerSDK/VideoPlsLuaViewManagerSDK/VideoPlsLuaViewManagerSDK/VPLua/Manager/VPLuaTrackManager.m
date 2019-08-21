//
//  VPLuaTrackManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/14.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaTrackManager.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPLuaNetworkManager.h"
#import "VPLuaSDK.h"
#import "VPLuaCommonInfo.h"

@implementation VPLuaTrackManager

+ (void)trackVideoModeSwitch:(BOOL)isOpen {

    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"statistic/collectVisionSwitchTimes"];
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    [param setObject:[VPLuaCommonInfo commonParam] forKey:@"commonParam"];
    [param setObject:[VPLuaSDK sharedSDK].appKey forKey:@"appKey"];
    [param setObject: isOpen ? @"1" : @"0" forKey:@"onOrOff"];
    
    api.requestParameters = param;
    //track do not handle completion
//    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
//
//    };
    [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
}

@end
