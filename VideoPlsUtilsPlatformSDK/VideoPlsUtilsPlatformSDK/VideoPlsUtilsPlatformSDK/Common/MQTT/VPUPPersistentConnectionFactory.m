//
//  VPUPPersistentConnectionFactory.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPPersistentConnectionFactory.h"
#import "VPUPServiceManager.h"
#import "VPUPPersistentConnectionDelegate.h"

@implementation VPUPPersistentConnectionFactory

+ (id<VPUPPersistentConnectionDelegate>)createPersistentConnectionWithType:(VPUPPersistentConnectionType)type {
    id<VPUPPersistentConnectionDelegate> persistentConnection = nil;
    switch (type) {
        case VPUPPersistentConnectionTypeCustom:
            persistentConnection = [[VPUPServiceManager sharedManager] createService:@protocol(VPUPPersistentConnectionDelegate)];
            break;
            
        default:
            break;
    }
    
    return persistentConnection;
}

@end
