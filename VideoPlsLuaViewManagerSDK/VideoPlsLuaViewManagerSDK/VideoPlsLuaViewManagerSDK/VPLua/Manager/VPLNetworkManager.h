//
//  VPLNetworkManager.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPPrefetchHeader.h"

@protocol VPUPHTTPAPIManager;
@protocol VPUPLoadImageManager;
@protocol VPUPMQTTManager;

@interface VPLNetworkManager : NSObject <NSCopying>

@property (nonatomic, strong) id<VPUPHTTPAPIManager> httpManager;
@property (nonatomic, strong) id<VPUPLoadImageManager> imageManager;
@property (nonatomic, strong) id<VPUPMQTTManager> mqttManager;
@property (nonatomic, strong) VPUPPrefetchVideoManager *videoManager;

+ (instancetype)Manager;
+ (void)releaseManaer;

@end
