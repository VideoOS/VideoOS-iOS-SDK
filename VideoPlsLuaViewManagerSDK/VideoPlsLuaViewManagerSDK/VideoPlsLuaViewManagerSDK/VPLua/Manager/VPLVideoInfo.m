//
//  VPLVideoInfo.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLVideoInfo.h"

@implementation VPLVideoInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    VPLVideoInfo *videoInfo = [[[self class] allocWithZone:zone] init];
    videoInfo.nativeID = _nativeID;
    videoInfo.platformID = _platformID;
    videoInfo.ssid = _ssid;
    videoInfo.projectID = _projectID;
    videoInfo.channelID = _channelID;
    videoInfo.category = _category;
    videoInfo.extendJSONString = _extendJSONString;
    videoInfo.title = _title;
    videoInfo.episode = _episode;
    
    return videoInfo;
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (!self.nativeID) {
        return nil;
    }
    
    [dict setObject:self.nativeID forKey:@"videoID"];
    if (self.title) {
        [dict setObject:self.title forKey:@"title"];
    } else {
        [dict setObject:@"" forKey:@"title"];
    }
    if (self.episode) {
        [dict setObject:self.episode forKey:@"episode"];
    } else {
        [dict setObject:@"" forKey:@"episode"];
    }
    
    if (self.category) {
        [dict setObject:self.category forKey:@"category"];
    }
    if (self.platformID) {
        [dict setObject:self.platformID forKey:@"platformID"];
    }
    if (self.projectID) {
        [dict setObject:self.projectID forKey:@"projectID"];
    }
    if (self.channelID) {
        [dict setObject:self.channelID forKey:@"channelID"];
    }
    
    
    return dict;
}

@end
