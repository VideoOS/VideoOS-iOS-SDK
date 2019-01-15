//
//  VPLuaNetworkManager.m
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaNetworkManager.h"
#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

static VPLuaNetworkManager *manager = nil;
static dispatch_once_t onceToken;

@implementation VPLuaNetworkManager

- (instancetype)copyWithZone:(NSZone *)zone {
    VPLuaNetworkManager *manager = [[[self class] allocWithZone:zone] init];
    manager.httpManager = _httpManager;
    manager.mqttManager = _mqttManager;
    manager.imageManager = _imageManager;
    manager.videoManager = _videoManager;
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
        _imageManager = [VPUPLoadImageFactory createWebImageManagerWithType:VPUPWebImageManagerTypeSD];
    }
    return self;
}

- (VPUPPrefetchVideoManager *)videoManager {
    if (_videoManager == nil) {
        _videoManager = [[VPUPPrefetchVideoManager alloc] init];
    }
    return _videoManager;
}

+ (instancetype)Manager {
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)releaseManaer {
    onceToken = 0;
    manager = nil;
}

@end

