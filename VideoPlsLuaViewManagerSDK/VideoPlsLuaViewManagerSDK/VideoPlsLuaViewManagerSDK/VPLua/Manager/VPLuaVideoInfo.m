//
//  VPLuaVideoInfo.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaVideoInfo.h"

@implementation VPLuaVideoInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    VPLuaVideoInfo *videoInfo = [[[self class] allocWithZone:zone] init];
    videoInfo.nativeID = _nativeID;
    videoInfo.platformID = _platformID;
    videoInfo.ssid = _ssid;
    videoInfo.projectID = _projectID;
    videoInfo.channelID = _channelID;
    videoInfo.category = _category;
    videoInfo.extendJSONString = _extendJSONString;
    
    return videoInfo;
}

@end
