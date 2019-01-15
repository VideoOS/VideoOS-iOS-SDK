//
//  VPUPMQTTManagerFactory.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol VPUPMQTTManager;

typedef NS_ENUM(NSUInteger, VPUPMQTTManagerType) {
    VPUPMQTTManagerTypeMosquitto    = 0
};

@interface VPUPMQTTManagerFactory : NSObject

+ (id<VPUPMQTTManager>)createMQTTManagerWithType:(VPUPMQTTManagerType)type;
@end
