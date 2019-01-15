//
//  VPUPDownloadBatchRequest.h
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPUPDownloadRequest;
@class VPUPDownloadBatchRequest;

typedef void (^VPUPDownloadBatchCompletionHandler)(VPUPDownloadBatchRequest *requests);

@interface VPUPDownloadBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<VPUPDownloadRequest *> *requestArray;
@property (nonatomic, copy) VPUPDownloadBatchCompletionHandler completionHandler;
@property (nonatomic, weak) dispatch_queue_t callbackQueue;

- (instancetype)initWithRequestArray:(NSArray<VPUPDownloadRequest *> *)requestArray;

- (void)addRequest:(VPUPDownloadRequest *)request;

- (void)addBatchRequests:(NSArray<VPUPDownloadRequest *> *)requestArray;

@end
