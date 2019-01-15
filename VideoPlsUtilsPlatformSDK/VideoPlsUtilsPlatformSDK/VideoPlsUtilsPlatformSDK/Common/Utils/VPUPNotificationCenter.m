//
//  VPUPNotificationCenter.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/23.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPNotificationCenter.h"

static VPUPNotificationCenter *defaultCenter = nil;
@implementation VPUPNotificationCenter

+ (VPUPNotificationCenter *)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    return defaultCenter;
}

- (instancetype)init {
    if(!defaultCenter) {
        defaultCenter = [super init];
    }
    return defaultCenter;
}

@end
