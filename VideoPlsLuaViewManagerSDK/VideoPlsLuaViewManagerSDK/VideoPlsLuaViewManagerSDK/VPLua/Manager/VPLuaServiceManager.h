//
//  VPLuaServiceManager.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaService.h"
#import "VPLuaOSView.h"
#import "VPLuaDesktopView.h"
#import "VPLuaTopView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * VPIServiceDelegate 是相关服务事件, 给服务进行简单的事件通知
 */
@protocol VPLuaServiceManagerDelegate<NSObject>

@optional

/**
 * 服务通知: 相关服务成功完成
 */
- (void)vp_didCompleteForService:(VPLuaServiceType )type;

/**
 * 服务通知: 相关服务执行失败
 */
- (void)vp_didFailToCompleteForService:(VPLuaServiceType )type error:(NSError *)error;

@end


@interface VPLuaServiceManager : NSObject

@property (nonatomic, weak) VPLuaOSView *osView;
@property (nonatomic, weak) VPLuaDesktopView *desktopView;
@property (nonatomic, weak) VPLuaTopView *topView;
@property (nonatomic, weak) id<VPLuaServiceManagerDelegate> delegate;
@property (nonatomic, readonly) NSMutableDictionary *serviceDict;

/**
 *  开始特定的服务
 */
- (void)startService:(VPLuaServiceType )type config:(VPLuaServiceConfig *)config;

/**
 *  重新开始特定的服务，用于前后帖视频广告
 */
- (void)resumeService:(VPLuaServiceType )type;

/**
 *  暂停特定的服务，用于前后帖视频广告
 */
- (void)pauseService:(VPLuaServiceType )type;

/**
 *  停止并销毁特定的服务
 */
- (void)stopService:(VPLuaServiceType)type;

@end

NS_ASSUME_NONNULL_END
