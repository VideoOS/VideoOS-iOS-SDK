//
//  VPIError.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 2019/7/16.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const VPIErrorDomain;

typedef NS_ENUM(NSInteger, VPIErrorCode) {
    /**
     *  没有错误
     */
    VPIErrorCodeNone                                = 0,
    /**
     *  The ad response was not recognized as a valid VAST ad.
     *  服务相关文件不存在
     */
    VPIErrorCodeServiceFileNotExists                = 1,       //视联网模式
    VPIErrorCodeServiceFileLoadError           = 2,       //视频广告，包括前后帖广告
    VPIErrorCodeServiceFileError         = 3,       //暂停广告
};

NS_ASSUME_NONNULL_BEGIN

@interface VPIError : NSObject

@end

NS_ASSUME_NONNULL_END
