//
//  VPUPDownloaderManager.m
//  ResumeDownloader
//
//  Created by peter on 14/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import "VPUPDownloaderManager.h"
#import "VPUPResumeDownloader.h"
#import "VPUPDownloadRequest.h"
#import "VPUPDownloadBatchRequest.h"

static const NSInteger VPUPDownloaderManagerMaxDownloaderCount = 3;
static NSString * const VPUPDownloaderManagerLockName = @"com.videopls.download.manager.lock";

typedef void (^VPUPDownloaderProgressBlock)(NSProgress *);
typedef void (^VPUPDownloaderCompletionHandler)(NSURL *filePath, NSError *error);

@interface VPUPDownloaderBatchRequest : NSObject

@property (nonatomic, strong) NSMutableArray *requestUrlArray;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *destination;
@property (nonatomic, copy) VPUPDownloaderProgressBlock progressBlock;
@property (nonatomic, copy) VPUPDownloaderCompletionHandler completionHandler;

@end

@implementation VPUPDownloaderBatchRequest

@end


@interface VPUPDownloaderManager()<VPUPResumeDownloaderDelegate>

@property (nonatomic, strong) NSMutableArray *downloaderArray;
@property (nonatomic, strong) NSMutableArray *requestArray;//等待下载的request
@property (nonatomic, strong) NSMutableArray *downloadingRequestArray;//正在下载的request
@property (readwrite, nonatomic, strong) NSLock *lock;
@property (nonatomic) dispatch_queue_t downloadBatchQueue;

@end

@implementation VPUPDownloaderManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static VPUPDownloaderManager *_shareManager = nil;
    dispatch_once(&onceToken, ^{
        _shareManager = [[self alloc] init];
    });
    return _shareManager;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.maxDownloaderCount = VPUPDownloaderManagerMaxDownloaderCount;
        self.downloaderArray = [NSMutableArray arrayWithCapacity:0];
        self.requestArray = [NSMutableArray arrayWithCapacity:0];
        self.downloadingRequestArray = [NSMutableArray arrayWithCapacity:0];
        self.lock = [[NSLock alloc] init];
        self.lock.name = VPUPDownloaderManagerLockName;
        self.downloadBatchQueue = dispatch_queue_create("com.videopls.download.batch", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)downloadWithRequest:(VPUPDownloadRequest *)request
{
    NSParameterAssert(request);
    [self.lock lock];
    BOOL isDownloadTargetUrl = NO;
    for (VPUPResumeDownloader *downloader in self.downloaderArray)
    {
        if ([request.downloadUrl isEqualToString:downloader.downloadUrl])
        {
            isDownloadTargetUrl = YES;
            break;
        }
    }
    if (isDownloadTargetUrl)
    {
        [self.downloadingRequestArray addObject:request];
        request.state = VPUPDownloadRequestStateLoading;
    }
    else
    {
        [self.requestArray addObject:request];
    }
    [self.lock unlock];
    [self createDownloader];
    
}

- (void)downloadWithBatchRequest:(VPUPDownloadBatchRequest *)requests
{
    dispatch_async(self.downloadBatchQueue, ^(void) {
        
        NSParameterAssert(requests);
        dispatch_group_t batch_group = dispatch_group_create();
        for (VPUPDownloadRequest *request in requests.requestArray)
        {
            request.completionGroup = batch_group;
            dispatch_group_enter(batch_group);
            [self downloadWithRequest:request];
        }
        
        dispatch_queue_t callbackQueue = [requests callbackQueue] ? : dispatch_get_main_queue();
        dispatch_group_notify(batch_group, callbackQueue, ^{
            if (requests.completionHandler) {
                requests.completionHandler(requests);
            }
        });
    });
}

- (void)createDownloader
{
    VPUPResumeDownloader *downloader = nil;
    [self.lock lock];
    if (self.downloaderArray.count < self.maxDownloaderCount && self.requestArray.count > 0)
    {
        VPUPDownloadRequest *request = [self.requestArray objectAtIndex:0];
        downloader = [[VPUPResumeDownloader alloc] initWithDownloadUrl:request.downloadUrl resumePath:request.destination];
        if (request.config & VPUPDownloadRequestConfigMaskFroceDownload)
        {
            downloader.isForceDownload = YES;
        }
        
        downloader.delegate = self;
        request.state = VPUPDownloadRequestStateLoading;
        [self.downloaderArray addObject:downloader];
        [self.downloadingRequestArray addObject:request];
        [self.requestArray removeObject:request];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
        for (VPUPDownloadRequest *request in self.requestArray)
        {
            if ([downloader.downloadUrl isEqualToString:request.downloadUrl])
            {
                [tempArray addObject:request];
            }
        }
        if (tempArray.count > 0)
        {
            for (VPUPDownloadRequest *request in tempArray)
            {
                [self.requestArray removeObject:request];
                [self.downloadingRequestArray addObject:request];
                request.state = VPUPDownloadRequestStateLoading;
            }
        }
    }
    [self.lock unlock];
    [downloader resume];
}

- (void)downloadCancelRequest:(VPUPDownloadRequest *)request
{
    NSString *errorStr     = @"User cancel the request";
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : errorStr
                               };
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:NSURLErrorCancelled
                                     userInfo:userInfo];
    
    switch (request.state) {
        case VPUPDownloadRequestStateWait:
            [self.lock lock];
            if ([self.requestArray containsObject:request])
            {
                [self.requestArray removeObject:request];
                request.state = VPUPDownloadRequestStateError;
                
                [self callRequestCompletion:request fileURL:nil error:error];
            }
            [self.lock unlock];
            break;
        case VPUPDownloadRequestStateLoading:
            [self.lock lock];
            if ([self.downloadingRequestArray containsObject:request])
            {
                BOOL isNeedCancelDownloader = YES;
                for (VPUPDownloadRequest *tempRequest in self.downloadingRequestArray)
                {
                    if (tempRequest != request && [tempRequest.downloadUrl isEqualToString:request.downloadUrl])
                    {
                        isNeedCancelDownloader = NO;
                        break;
                    }
                }
                [self.downloadingRequestArray removeObject:request];
                if (isNeedCancelDownloader)
                {
                    VPUPResumeDownloader *downloader = nil;
                    for (VPUPResumeDownloader *tempDownloader in self.downloaderArray)
                    {
                        if ([tempDownloader.downloadUrl isEqualToString:request.downloadUrl])
                        {
                            downloader = tempDownloader;
                            break;
                        }
                    }
                    [downloader cancel];
                    [downloader invalidate];
                    [self.downloaderArray removeObject:downloader];
                }
                request.state = VPUPDownloadRequestStateError;
                
                [self callRequestCompletion:request fileURL:nil error:error];
            }
            [self.lock unlock];
            break;
            
        default:
            break;
    }
}

- (void)downloadCancelBatchRequest:(VPUPDownloadBatchRequest *)requests
{
    NSParameterAssert(requests);
    for (VPUPDownloadRequest *request in requests.requestArray)
    {
        [self downloadCancelRequest:request];
    }
}

- (void)downloadRetryRequest:(VPUPDownloadRequest *)request
{
    NSParameterAssert(request);
    if (request.state == VPUPDownloadRequestStateError)
    {
        request.state = VPUPDownloadRequestStateWait;
        if(request.completionGroup)
        {
            dispatch_group_enter(request.completionGroup);
        }
        [request addTryCount];
        [self downloadWithRequest:request];
    }
}

- (void)callRequestCompletion:(VPUPDownloadRequest *)request
                      fileURL:(NSURL *)location
                        error:(NSError *)error
{
    if (request.completionHandler)
    {
        dispatch_queue_t callBackQueue = request.callbackQueue ? : dispatch_get_main_queue();
        dispatch_async(callBackQueue, ^{
            request.completionHandler(location, error);
        });
    }
    if (request.completionGroup)
    {
        dispatch_group_leave(request.completionGroup);
    }
}

#pragma VPUPResumeDownloaderDelegate
- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location
{
    [self.lock lock];
    NSMutableArray *finishedRequestArray = [NSMutableArray array];
    for(VPUPDownloadRequest *request in self.downloadingRequestArray)
    {
        if ([request.downloadUrl isEqualToString:downloader.downloadUrl])
        {
            request.state = VPUPDownloadRequestStateSuccess;
            [finishedRequestArray addObject:request];
            [self callRequestCompletion:request fileURL:location error:nil];
        }
    }
    for(VPUPDownloadRequest *request in finishedRequestArray)
    {
        [self.downloadingRequestArray removeObject:request];
    }
    [self.downloaderArray removeObject:downloader];
    [self.lock unlock];
    [self createDownloader];
}

- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [self.lock lock];
    for(VPUPDownloadRequest *request in self.downloadingRequestArray)
    {
        if ([request.downloadUrl isEqualToString:downloader.downloadUrl])
        {
            if (request.progressBlock)
            {
                dispatch_queue_t callBackQueue = request.callbackQueue ? : dispatch_get_main_queue();
                dispatch_async(callBackQueue, ^{
                    request.progressBlock(downloader.progress);
                });
            }
        }
    }
    [self.lock unlock];
}

- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didCompleteWithError:(NSError *)error
{
    if (error)
    {
        NSMutableArray *finishedRequestArray = [NSMutableArray array];
        [self.lock lock];
        for(VPUPDownloadRequest *request in self.downloadingRequestArray)
        {
            if ([request.downloadUrl isEqualToString:downloader.downloadUrl])
            {
                request.state = VPUPDownloadRequestStateError;
                [finishedRequestArray addObject:request];
            }
        }
        //删除已经完成的request，这次删除和下面的try不能在一起执行，否则tryRequest不能添加到等待队列中
        for(VPUPDownloadRequest *request in finishedRequestArray)
        {
            [self.downloadingRequestArray removeObject:request];
        }
        [self.downloaderArray removeObject:downloader];
        [self.lock unlock];
        for(VPUPDownloadRequest *request in finishedRequestArray)
        {
            //request.tryCount已经达到配置的值，或大于2时结束
            if (request.config & 1 << request.tryCount || request.tryCount > 2)
            {
                [self callRequestCompletion:request fileURL:nil error:error];
            }
            else
            {
                [self downloadRetryRequest:request];
                if(request.completionGroup)
                {
                    dispatch_group_leave(request.completionGroup);
                }
            }
        }
    }
    [self createDownloader];
}

@end
