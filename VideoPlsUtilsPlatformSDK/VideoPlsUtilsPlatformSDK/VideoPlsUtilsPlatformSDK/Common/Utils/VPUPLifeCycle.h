//
//  VPUPLifeCycle.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const VPUPLifeCycleStartNotification;
extern NSString *const VPUPLifeCycleStopNotification;
extern NSString *const VPUPVideoStartNotification;
extern NSString *const VPUPVideoStopNotification;


@interface VPUPLifeCycle : NSObject

//进入页面,需要进行一些初始化
+ (void)startLifeCycle;

//关闭页面,结束这次生命周期,注:同一页面开启不同的点播直播不需要关闭生命周期
+ (void)stopLifeCycle;


//打开视频时调用
+ (void)startVideo;

//关闭视频时调用
+ (void)stopVideo;



+ (BOOL)isInLifeCycle;

+ (BOOL)isInVideo;

@end
