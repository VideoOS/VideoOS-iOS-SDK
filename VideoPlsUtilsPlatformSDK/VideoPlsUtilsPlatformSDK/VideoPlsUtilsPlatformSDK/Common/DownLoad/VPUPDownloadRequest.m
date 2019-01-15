//
//  VPUPDownloadRequest.m
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import "VPUPDownloadRequest.h"

static const NSInteger VPUPDownloadRequestTimeoutInterval = 30;

@interface VPUPDownloadRequest()

@property (nonatomic, readwrite, copy) NSString *downloadUrl;
@property (nonatomic, readwrite, assign) NSInteger tryCount;

@end

@implementation VPUPDownloadRequest

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
{
    return [self initWithDownloadUrl:downloadUrl destination:nil];
}

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                        destination:(NSString*)destination
{
    return [self initWithDownloadUrl:downloadUrl destination:destination progress:nil completionHandler:nil];
}

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                        destination:(NSString*)destination
                           progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                  completionHandler:(void (^)(NSURL *filePath, NSError *error))completionHandler
{
    self = [super init];
    if (!self||!downloadUrl)
    {
        return nil;
    }

    self.downloadUrl = downloadUrl;
    self.destination = destination;
    self.progressBlock = downloadProgressBlock;
    self.completionHandler = completionHandler;
    self.config = VPUPDownloadRequestConfigMaskNormal;
    self.state = VPUPDownloadRequestStateWait;
    self.timeoutInterval = VPUPDownloadRequestTimeoutInterval;
    self.tryCount = 0;
    return self;
}

- (void)addTryCount
{
    self.tryCount += 1;
}

@end
