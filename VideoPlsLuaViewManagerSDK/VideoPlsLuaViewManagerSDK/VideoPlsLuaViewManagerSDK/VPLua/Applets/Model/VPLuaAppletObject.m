//
//  VPLuaAppletObject.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletObject.h"
#import "VPUPHexColors.h"

@implementation VPLuaAppletObject

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict {
    VPLuaAppletObject *applet = [[VPLuaAppletObject alloc] init];
    if ([dict objectForKey:@"miniAppInfo"]) {
        applet.miniAppInfo = [VPMiniAppInfo initWithResponseDictionary:[dict objectForKey:@"miniAppInfo"]];
    }
    if ([dict objectForKey:@"attachInfo"]) {
        applet.attachInfo = [dict objectForKey:@"attachInfo"];
    }
    if ([dict objectForKey:@"h5Url"]) {
        applet.h5Url = [dict objectForKey:@"h5Url"];
    }
    if ([dict objectForKey:@"display"]) {
        applet.naviSetting = [VPAppletContainerNaviSetting initWithDictionary:[dict objectForKey:@"display"]];
    }
    
    return applet;
}

@end
