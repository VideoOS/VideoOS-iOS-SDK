//
//  VPUPHTTPManagerFactory.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPManagerFactory.h"
#import "VPUPServiceManager.h"
#import "VPUPHTTPManager.h"

@implementation VPUPHTTPManagerFactory

//调用VPUPHTTPManagerFactory时，若没有实现VPUPHTTPAPIManager协议，使用VPUPHTTPManager
+ (void)initialize {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPHTTPAPIManager) implClass:[VPUPHTTPManager class]];
}

+ (id<VPUPHTTPAPIManager>)createHTTPAPIManagerWithType:(VPUPHTTPManagerType)type {
    id<VPUPHTTPAPIManager> manager = nil;
    switch (type) {
        case VPUPHTTPManagerTypeAFN:
//            manager = [[VPUPHTTPAFNManager alloc] init];
            manager = [[VPUPServiceManager sharedManager] createService:@protocol(VPUPHTTPAPIManager)];
            break;
            
        default:
            break;
    }
    return manager;
}

@end
