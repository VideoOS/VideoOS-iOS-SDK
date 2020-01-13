//
//  VPUPCommonTrack.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/11/7.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 数据统计类型
typedef NS_ENUM(NSUInteger, VPUPCommonTrackType) {
    VPUPCommonTrackTypeJump         = 1,        //工具类小程序或服务性小程序之间跳转统计
    VPUPCommonTrackTypeEvent        = 2,        //用户行为统计
    VPUPCommonTrackTypeVideoNet     = 3,        //视联网开关次数统计
    VPUPCommonTrackTypeNotice       = 4,        //notice接口状态统计
    VPUPCommonTrackTypeTraffic      = 5,        //预加载流量统计
    VPUPCommonTrackTypeOpenMP       = 6,        //小程序启动
    VPUPCommonTrackTypeCloseMP      = 7,        //小程序关闭
    VPUPCommonTrackTypePageName     = 8         //小程序页面统计
};


@interface VPUPCommonTrack : NSObject

+ (VPUPCommonTrack *)shared;

- (void)sendTrackWithType:(VPUPCommonTrackType)trackType dataDict:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
