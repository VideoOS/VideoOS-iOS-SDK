//
//  VPUPDownloadRequest.h
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VPUPDownloadRequestState) {
    VPUPDownloadRequestStateUnknown,
    VPUPDownloadRequestStateWait,
    VPUPDownloadRequestStateLoading,
    VPUPDownloadRequestStateSuccess,
    VPUPDownloadRequestStateError
};

typedef NS_ENUM(NSInteger, VPUPDownloadRequestConfig) {
    VPUPDownloadRequestConfigNormal,
    VPUPDownloadRequestConfigTryOnce,
    VPUPDownloadRequestConfigTryTwice,
    VPUPDownloadRequestConfigFroceDownload
};

typedef NS_OPTIONS(NSUInteger, VPUPDownloadRequestConfigMask) {
    VPUPDownloadRequestConfigMaskNormal = (1 << VPUPDownloadRequestConfigNormal),
    VPUPDownloadRequestConfigMaskTryOnce = (1 << VPUPDownloadRequestConfigTryOnce),
    VPUPDownloadRequestConfigMaskTryTwice = (1 << VPUPDownloadRequestConfigTryTwice),
    VPUPDownloadRequestConfigMaskFroceDownload = (1 << VPUPDownloadRequestConfigFroceDownload),
    VPUPDownloadRequestConfigMaskFroceDownloadTryOnce = (VPUPDownloadRequestConfigMaskFroceDownload | VPUPDownloadRequestConfigMaskTryOnce),
    VPUPDownloadRequestConfigMaskFroceDownloadTryTwice = (VPUPDownloadRequestConfigMaskFroceDownload | VPUPDownloadRequestConfigMaskTryTwice)
};

typedef void (^VPUPDownloadProgressBlock)(NSProgress *);
typedef void (^VPUPDownloadCompletionHandler)(NSURL *filePath, NSError *error);

@interface VPUPDownloadRequest : NSObject

@property (nonatomic, readonly) NSString *downloadUrl;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, assign) VPUPDownloadRequestConfigMask config;
@property (nonatomic, copy) VPUPDownloadProgressBlock progressBlock;
@property (nonatomic, copy) VPUPDownloadCompletionHandler completionHandler;
@property (nonatomic, assign) VPUPDownloadRequestState state;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign, readonly) NSInteger tryCount;
@property (nonatomic, weak) dispatch_queue_t callbackQueue;
@property (nonatomic, strong) dispatch_group_t completionGroup;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                        destination:(NSString*)destination;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                        destination:(NSString*)destination
                           progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                  completionHandler:(void (^)(NSURL *filePath, NSError *error))completionHandler;

- (void)addTryCount;

@end
