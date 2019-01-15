//
//  VPUPDebugSwitch.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 运行环境
typedef NS_ENUM(NSUInteger, VPUPDebugState) {
    VPUPDebugStateOnline        = 0,        //正式环境
    VPUPDebugStateProduction    = 1,        //生产环境
    VPUPDebugStateTest          = 2,        //测试环境
    VPUPDebugStateDevelop       = 3         //开发环境
};

extern NSString *const VPUPDebugPanelPostReportLogNotification;
extern NSString *const VPUPLogAddReportNotification;

@protocol VPUPDebugSwitchProtocol <NSObject>

- (void)switchEnvironmentTo:(VPUPDebugState)debugState;

@end

@interface VPUPDebugSwitch : NSObject

+ (VPUPDebugSwitch *)sharedDebugSwitch;


/**
 *  默认为 VPUPDebugStateOnline
 */
@property (nonatomic, assign, readonly) VPUPDebugState debugState;

/**
 *  是否打印log,默认为
 *  VPUPDebugStateOnline & VPUPDebugStateProduction 关闭
 *  VPUPDebugStateDebug  & VPUPDebugStateDevelop    开启
 */
@property (nonatomic, assign, readonly, getter=isLogEnable) BOOL logEnable;

/**
 *  手势控制,默认为关闭
 */
@property (nonatomic, assign, readonly, getter=isGestureEnable) BOOL gestureEnable;

/**
 *  关闭日志输出
 */
- (void)disableLogging;

/**
 *  开启日志输出
 */
- (void)enableLogging;



/**
 *  手动切换环境
 *  @param environment VPUPDebugState
 */
- (void)switchEnvironment:(VPUPDebugState)environment;


/**
 *  添加切换运行环境后的通知
 *
 *  @param observer 遵循VPUPDebugSwitchProtocol的observer
 */
- (void)registerDebugSwitchObserver:(nonnull id<VPUPDebugSwitchProtocol>)observer;

/**
 *  删除切换运行环境时的监控observer
 *
 *  @param observer 遵循VPUPDebugSwitchProtocol的observer
 */
- (void)removeDebugSwitchObserver:(nonnull id<VPUPDebugSwitchProtocol>)observer;

@end
NS_ASSUME_NONNULL_END
