//
//  VPUPSVGAPlayerFactory.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 26/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPSVGAPlayerProtocol.h"

typedef NS_ENUM(NSInteger, VPUPSVGAPlayerType) {
    VPUPSVGAPlayerTypeCustom = 0                         // no VPUPSVGAPlayer type
};

@interface VPUPSVGAPlayerFactory : NSObject

+ (id<VPUPSVGAPlayerProtocol>)createSVGAPlayerWithType:(VPUPSVGAPlayerType)type;

@end
