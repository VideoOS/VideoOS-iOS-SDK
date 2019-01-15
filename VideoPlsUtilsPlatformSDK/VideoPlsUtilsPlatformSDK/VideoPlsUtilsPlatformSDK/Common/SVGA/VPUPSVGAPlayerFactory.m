//
//  VPUPSVGAPlayerFactory.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 26/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPSVGAPlayerFactory.h"
#import "VPUPServiceManager.h"

@implementation VPUPSVGAPlayerFactory

+ (id<VPUPSVGAPlayerProtocol>)createSVGAPlayerWithType:(VPUPSVGAPlayerType)type {
    id<VPUPSVGAPlayerProtocol> player = nil;
    switch (type) {
        case VPUPSVGAPlayerTypeCustom:
            player = [[VPUPServiceManager sharedManager] createService:@protocol(VPUPSVGAPlayerProtocol)];;
            break;
            
        default:
            player = [[VPUPServiceManager sharedManager] createService:@protocol(VPUPSVGAPlayerProtocol)];;
            break;
    }
    return player;
}

@end
