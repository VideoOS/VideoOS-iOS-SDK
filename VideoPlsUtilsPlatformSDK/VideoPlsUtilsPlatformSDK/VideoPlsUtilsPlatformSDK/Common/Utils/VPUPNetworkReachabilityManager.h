//
//  VPUPNetworkReachabilityManager.h
//  ResumeDownloader
//
//  Created by peter on 16/11/2017.
//  Copyright © 2017 JSS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPUPNetworkReachabilityStatus) {
    VPUPNetworkReachabilityStatusUnknown          = -1,
    VPUPNetworkReachabilityStatusNotReachable     = 0,
    VPUPNetworkReachabilityStatusReachableViaWiFi,
    VPUPNetworkReachabilityStatusReachableVia2G,
    VPUPNetworkReachabilityStatusReachableVia3G,
    VPUPNetworkReachabilityStatusReachableVia4G,
    VPUPNetworkReachabilityStatusReachableViaWWAN
};

FOUNDATION_EXPORT NSString * const VPUPNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const VPUPNetworkingReachabilityNotificationStatusItem;

@interface VPUPNetworkReachabilityManager : NSObject

+ (instancetype)sharedManager;

/**
 The current network reachability status.
 */
@property (readonly, nonatomic, assign) VPUPNetworkReachabilityStatus networkReachabilityStatus;

/**
 Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

- (VPUPNetworkReachabilityStatus)currentReachabilityStatus;

- (NSString *)currentReachabilityStatusString;

@end
