//
//  VPUPPersistentConnectionFactory.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/27.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VPUPPersistentConnectionDelegate;

typedef NS_ENUM(NSUInteger, VPUPPersistentConnectionType) {
    VPUPPersistentConnectionTypeCustom    = 0
};

@interface VPUPPersistentConnectionFactory : NSObject

+ (id<VPUPPersistentConnectionDelegate>)createPersistentConnectionWithType:(VPUPPersistentConnectionType)type;

@end
