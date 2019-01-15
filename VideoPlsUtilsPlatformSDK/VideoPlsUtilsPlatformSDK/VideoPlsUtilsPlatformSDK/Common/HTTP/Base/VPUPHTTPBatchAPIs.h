//
//  VPUPHTTPBatchAPIs.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPUPHTTPBaseAPI;
@class VPUPHTTPBatchAPIs;

@protocol VPUPAPIHTTPBatchAPIsProtocol <NSObject>

/**
 *  Batch Requests 全部调用完成之后调用
 *
 *  @param batchApis batchApis
 */
- (void)batchAPIRequestsDidFinished:(nonnull VPUPHTTPBatchAPIs *)batchApis;

@end

@interface VPUPHTTPBatchAPIs : NSObject

/**
 *  发送completeBlock使用的线程
 *  可手动配置,如果为空则默认为main_queue
 *  注: 每个单独api的complete是回自己的callbackQueue中执行
 */
@property (nullable, nonatomic, weak) dispatch_queue_t callbackQueue;

/**
 *  Batch 执行的API Requests 集合
 */
@property (nonatomic, strong, readonly, nullable) NSMutableSet *apiRequestsSet;

/**
 *  Batch Requests 执行完成之后调用的delegate
 */
@property (nonatomic, weak, nullable) id<VPUPAPIHTTPBatchAPIsProtocol> delegate;

/**
 *  将API 加入到BatchRequest Set 集合中
 *
 *  @param api api
 */
- (void)addAPIRequest:(nonnull VPUPHTTPBaseAPI *)api;

/**
 *  将带有API集合的Sets 赋值
 *
 *  @param apis apis
 */
- (void)addBatchAPIRequests:(nonnull NSSet *)apis;


@end
