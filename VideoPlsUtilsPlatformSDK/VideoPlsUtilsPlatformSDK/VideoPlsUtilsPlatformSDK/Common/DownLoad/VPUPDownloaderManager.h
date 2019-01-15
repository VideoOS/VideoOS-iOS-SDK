//
//  VPUPDownloaderManager.h
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPUPDownloadRequest;
@class VPUPDownloadBatchRequest;

@interface VPUPDownloaderManager : NSObject

@property (nonatomic, assign) NSInteger maxDownloaderCount;

+ (instancetype)sharedManager;

- (void)downloadWithRequest:(VPUPDownloadRequest *)request;

- (void)downloadWithBatchRequest:(VPUPDownloadBatchRequest *)requests;

- (void)downloadCancelRequest:(VPUPDownloadRequest *)request;

- (void)downloadCancelBatchRequest:(VPUPDownloadBatchRequest *)requests;

@end
