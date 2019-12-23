//
//  VPLMPObject.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPObject.h"
#import "VPUPHexColors.h"

@implementation VPLMPObject

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict {
    VPLMPObject *mpObject = [[VPLMPObject alloc] init];
    if ([dict objectForKey:@"miniAppInfo"]) {
        mpObject.miniAppInfo = [VPMiniAppInfo initWithResponseDictionary:[dict objectForKey:@"miniAppInfo"]];
    }
    if ([dict objectForKey:@"attachInfo"]) {
        mpObject.attachInfo = [dict objectForKey:@"attachInfo"];
    }
    if ([dict objectForKey:@"h5Url"]) {
        mpObject.h5Url = [dict objectForKey:@"h5Url"];
    }
    if ([dict objectForKey:@"display"]) {
        mpObject.naviSetting = [VPMPContainerNaviSetting initWithDictionary:[dict objectForKey:@"display"]];
    }
    
    return mpObject;
}

@end
