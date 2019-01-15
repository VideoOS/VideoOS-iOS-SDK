//
//  VPUPHTTPManagerFactory.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIManager.h"

typedef NS_ENUM(NSUInteger, VPUPHTTPManagerType) {
    VPUPHTTPManagerTypeAFN      = 0
};

@interface VPUPHTTPManagerFactory : NSObject

+ (id<VPUPHTTPAPIManager>)createHTTPAPIManagerWithType:(VPUPHTTPManagerType)type;

@end
