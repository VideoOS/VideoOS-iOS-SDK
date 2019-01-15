//
//  VPUPInterfaceDataServiceManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 24/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPVideoPlayerSize.h"

@protocol VPUPInterfaceDataServiceManagerDelegate<NSObject>

- (NSDictionary*)getUserInfo;

- (NSTimeInterval)videoPlayerCurrentItemAssetDuration;

- (NSTimeInterval)videoPlayerCurrentTime;

- (VPUPVideoPlayerSize *)videoPlayerSize;

@end


@interface VPUPInterfaceDataServiceManager : NSObject

/**
 Creates a new VPUPDataServiceManager.
 
 @param delegate The object implements the VPUPDataServiceManagerDelegate protocol.
 
 @returns The newly initialized VPUPDataServiceManager.
 */
- (instancetype)initWithVPUPInterfaceDataServiceManagerDelegate:(id<VPUPInterfaceDataServiceManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithVPUPDataServiceManagerDelegate: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithVPUPDataServiceManagerDelegate: instead.
+ (instancetype)new NS_UNAVAILABLE;

+ (void)managerWithVPUPDataServiceManagerDelegate:(id<VPUPInterfaceDataServiceManagerDelegate>)delegate;

+ (NSDictionary*)getUserInfo;
+ (NSTimeInterval)videoPlayerCurrentItemAssetDuration;
+ (NSTimeInterval)videoPlayerCurrentTime;
+ (VPUPVideoPlayerSize *)videoPlayerSize;

+ (void)deallocManager;

@end
