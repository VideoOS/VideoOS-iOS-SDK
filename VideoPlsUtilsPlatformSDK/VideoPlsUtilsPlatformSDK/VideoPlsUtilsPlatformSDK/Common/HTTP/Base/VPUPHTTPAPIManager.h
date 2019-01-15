//
//  VPUPHTTPAPIManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPHTTPBaseAPI;
@class VPUPHTTPBatchAPIs;
@class VPUPHTTPManagerConfig;
@protocol VPUPNetworkErrorObserverProtocol;

NS_ASSUME_NONNULL_BEGIN
@protocol VPUPHTTPAPIManager <NSObject>

//apiManager config
@property (nonatomic, readonly) VPUPHTTPManagerConfig *configuration;

/**
 *  发送API请求
 *
 *  @param api 要发送的api
 */
- (void)sendAPIRequest:(nonnull VPUPHTTPBaseAPI *)api;

/**
 *  取消API请求
 *
 *  @description
 *      如果该请求已经发送或者正在发送，则无法取消
 *
 *  @param api 要取消的api
 */
- (void)cancelAPIRequest:(nonnull VPUPHTTPBaseAPI  *)api;

/**
 *  发送一系列API请求
 *
 *  @param apis 待发送的API请求集合
 */
- (void)sendBatchAPIRequests:(nonnull VPUPHTTPBatchAPIs *)apis;

/**
 *  取消所有API
 */
- (void)cancelAll;

/**
 *  设置最大HTTP可连接数,[1,10].最好在创建时就进行修改,如果有已经请求过,则该baseUrl下的sessionManager无法应用这个最大连接数
 */
- (void)setMaxHTTPConnection:(NSUInteger)maxHTTPConnect;

@end
NS_ASSUME_NONNULL_END
