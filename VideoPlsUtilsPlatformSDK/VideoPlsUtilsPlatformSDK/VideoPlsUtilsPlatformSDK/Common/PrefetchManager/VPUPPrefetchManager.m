//
//  VPUPPrefetchManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPPrefetchManager.h"
#import "VPUPHTTPNetworking.h"
#import "VPUPDownloadRequest.h"
#import "VPUPDownloadBatchRequest.h"
#import "VPUPDownloaderManager.h"

@interface VPUPPrefetchManager ()

@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation VPUPPrefetchManager {
//    NSMutableArray *_cacheAPIs;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.maxConcurrentDownloads = 5;
        self.prefetcherQueue = dispatch_get_main_queue();
        self.requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)prefetchURLs:(NSArray *)urls
           fileNames:(NSArray *)fileNames
     destinationPath:(NSString *)destinationPath {
    [self prefetchURLs:urls fileNames:fileNames destinationPath:destinationPath completionBlock:nil];
}

- (void)prefetchURLs:(NSArray *)urls
           fileNames:(NSArray *)fileNames
     destinationPath:(NSString *)destinationPath
     completionBlock:(VPUPPrefetcherCompletionBlock)completionBlock {
    
    NSAssert(urls, @"urls couldn't be nil");
    NSAssert(fileNames, @"fileNames couldn't be nil");
    NSAssert([urls count] == [fileNames count], @"urls' count must be equal to fileNames' count");
    NSAssert(destinationPath, @"destinationPath couldn't be nil");
    
    if (!urls || urls.count == 0) {
        if (completionBlock) {
            completionBlock(0,0);
        }
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    VPUPDownloadBatchRequest *batchRequest = [[VPUPDownloadBatchRequest alloc] init];
    
    for (int i = 0; i < urls.count; i++) {
        NSString *prefetchUrl = [urls objectAtIndex:i];
        NSString *fileName = [fileNames objectAtIndex:i];
        NSString *filePath = [destinationPath stringByAppendingPathComponent:fileName];
        VPUPDownloadRequest *request = [[VPUPDownloadRequest alloc] initWithDownloadUrl:prefetchUrl
                                                                            destination:filePath
                                                                               progress:nil
                                                                      completionHandler:nil];
        [batchRequest addRequest:request];
    }
    __weak typeof(self) weakSelf = self;
    batchRequest.completionHandler = ^(VPUPDownloadBatchRequest *requests) {
        if (completionBlock) {
            NSUInteger numberOfFinishedUrls = 0;
            NSUInteger numberOfSkippedUrls = 0;
            for (VPUPDownloadRequest *request in requests.requestArray) {
                if (request.state == VPUPDownloadRequestStateSuccess) {
                    numberOfFinishedUrls++;
                }
                else {
                    numberOfSkippedUrls++;
                }
            }
            completionBlock(numberOfFinishedUrls,numberOfSkippedUrls);
        }
        [weakSelf.requestArray removeObject:requests];
    };
    
    [self.requestArray addObject:batchRequest];
    [[VPUPDownloaderManager sharedManager] downloadWithBatchRequest:batchRequest];
}

- (void)cancelPrefetch {
    
    for (VPUPDownloadBatchRequest *request in self.requestArray) {
        [[VPUPDownloaderManager sharedManager] downloadCancelBatchRequest:request];
    }
//    [_cacheAPIs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [_httpManager cancelAPIRequest:obj];
//    }];
//    
//    [_cacheAPIs removeAllObjects];
}

@end
