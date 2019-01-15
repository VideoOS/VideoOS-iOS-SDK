//
//  VPUPWebImageFactory.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol VPUPLoadImageManager;

typedef NS_ENUM(NSUInteger, VPUPWebImageManagerType) {
    VPUPWebImageManagerTypeSD    = 0
};

@interface VPUPLoadImageFactory : NSObject

+ (id<VPUPLoadImageManager>)createWebImageManagerWithType:(VPUPWebImageManagerType)type;

@end
