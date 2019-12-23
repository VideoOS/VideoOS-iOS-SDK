//
//  VPLServiceManager.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLService.h"
#import "VPLOSView.h"
#import "VPLBubbleView.h"
#import "VPLTopView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * VPIServiceDelegate 是相关服务事件, 给服务进行简单的事件通知
 */
@protocol VPLServiceManagerDelegate<NSObject>

@optional

/**
 * 服务通知: 相关服务成功完成
 */
- (void)vp_didCompleteForService:(VPLServiceType )type;

/**
 * 服务通知: 相关服务执行失败
 */
- (void)vp_didFailToCompleteForService:(VPLServiceType )type error:(NSError *)error;

@end


@interface VPLServiceManager : NSObject

@property (nonatomic, weak) VPLOSView *osView;
@property (nonatomic, weak) VPLBubbleView *bubbleView;
@property (nonatomic, weak) VPLTopView *topView;
@property (nonatomic, weak) id<VPLServiceManagerDelegate> delegate;
@property (nonatomic, readonly) NSMutableDictionary *serviceDict;

/**
 *  开始特定的服务
 */
- (void)startService:(VPLServiceType )type config:(VPLServiceConfig *)config;

/**
 *  重新开始特定的服务，用于前后帖视频广告
 */
- (void)resumeService:(VPLServiceType )type;

/**
 *  暂停特定的服务，用于前后帖视频广告
 */
- (void)pauseService:(VPLServiceType )type;

/**
 *  停止并销毁特定的服务
 */
- (void)stopService:(VPLServiceType)type;

@end

NS_ASSUME_NONNULL_END
