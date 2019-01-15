//
//  VPUPMQTTManagerFactory.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPMQTTManagerFactory.h"
#import "VPUPMQTTMosquittoManager.h"

@implementation VPUPMQTTManagerFactory

+ (id<VPUPMQTTManager>)createMQTTManagerWithType:(VPUPMQTTManagerType)type {
    
    id<VPUPMQTTManager>manager = nil;
    switch (type) {
        case VPUPMQTTManagerTypeMosquitto:
            manager = [[VPUPMQTTMosquittoManager alloc] init];
            break;
            
        default:
            break;
    }
    
    return manager;
}

@end
