//
//  VPUPWebImageFactory.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLoadImageFactory.h"
#import "VPUPLoadImageManager.h"
#import "VPUPServiceManager.h"

@implementation VPUPLoadImageFactory

+ (id<VPUPLoadImageManager>)createWebImageManagerWithType:(VPUPWebImageManagerType)type {
    
    id<VPUPLoadImageManager>manager = nil;
    switch (type) {
        case VPUPWebImageManagerTypeSD:
//            manager = [[VPUPLoadImageSDManager alloc] init];
            manager = [[VPUPServiceManager sharedManager] createService:@protocol(VPUPLoadImageManager)];
            break;
            
        default:
            break;
    }
    return manager;
}

@end
