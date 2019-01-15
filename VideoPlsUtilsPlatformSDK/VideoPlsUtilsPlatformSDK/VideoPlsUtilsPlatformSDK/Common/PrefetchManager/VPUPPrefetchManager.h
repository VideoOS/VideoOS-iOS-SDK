//
//  VPUPPrefetchManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIManager.h"

typedef void(^VPUPPrefetcherCompletionBlock)(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls);

@interface VPUPPrefetchManager : NSObject {
    NSArray *_prefetchURLs;
    NSArray *_fileNames;
    NSString *_destinationPath;
    
    NSUInteger _requestedCount;
    NSUInteger _skippedCount;
    NSUInteger _finishedCount;
    NSTimeInterval _startedTime;
    
    id<VPUPHTTPAPIManager> _httpManager;
}

/**
 * Maximum number of URLs to prefetch at the same time. Defaults to 5. Image Prefetch to 5. Video Prefetch to 1.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

/**
 * Queue options for Prefetcher. Defaults to Main Queue.
 */
@property (nonatomic, assign) dispatch_queue_t prefetcherQueue;


@property (nonatomic, copy) VPUPPrefetcherCompletionBlock completionBlock;

//Image Prefetch needn't pass fileNames or destinationPath, It is of no effect
- (void)prefetchURLs:(NSArray<NSString *> *)urls
           fileNames:(NSArray<NSString *> *)fileNames
     destinationPath:(NSString *)destinationPath;

- (void)prefetchURLs:(NSArray<NSString *> *)urls
           fileNames:(NSArray<NSString *> *)fileNames
     destinationPath:(NSString *)destinationPath
     completionBlock:(VPUPPrefetcherCompletionBlock)completionBlock;

- (void)cancelPrefetch;

@end
