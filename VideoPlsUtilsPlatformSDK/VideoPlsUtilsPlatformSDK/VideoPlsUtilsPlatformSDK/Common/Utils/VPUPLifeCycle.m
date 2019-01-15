//
//  VPUPLifeCycle.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLifeCycle.h"
#import "VPUPNotificationCenter.h"
#import "VPUPGeneralInfo.h"

NSString *const VPUPLifeCycleStartNotification = @"VPUPLifeCycleStartNotification";
NSString *const VPUPLifeCycleStopNotification = @"VPUPLifeCycleStopNotification";
NSString *const VPUPVideoStartNotification = @"VPUPVideoStartNotification";
NSString *const VPUPVideoStopNotification = @"VPUPVideoStopNotification";

static BOOL isInLifeCycle = NO;
static BOOL isInVideo = NO;

@implementation VPUPLifeCycle

+ (void)startLifeCycle {
    if(!isInLifeCycle) {
        isInLifeCycle = YES;
        [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPLifeCycleStartNotification object:nil];
        [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUseSDKInfo) name:VPUPGeneralInfoSDKChangedNotification object:nil];
    }
}

+ (void)stopLifeCycle {
    if(isInLifeCycle) {
        if(isInVideo) {
            [self stopVideo];
        }
        isInLifeCycle = NO;
        [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPLifeCycleStopNotification object:nil];
        [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPGeneralInfoSDKChangedNotification object:nil];
    }
}


+ (void)startVideo {
    if(isInLifeCycle) {
        if(!isInVideo) {
            isInVideo = YES;
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPVideoStartNotification object:nil];
        }
    }
}

+ (void)stopVideo {
    if(isInLifeCycle) {
        if(isInVideo) {
            isInVideo = NO;
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPVideoStopNotification object:nil];
        }
    }
}

+ (void)changeUseSDKInfo {
//    if(isInVideo) {
//        [self stopVideo];
//    }
}


+ (BOOL)isInLifeCycle {
    return isInLifeCycle;
}

+ (BOOL)isInVideo {
    return isInVideo;
}

@end
