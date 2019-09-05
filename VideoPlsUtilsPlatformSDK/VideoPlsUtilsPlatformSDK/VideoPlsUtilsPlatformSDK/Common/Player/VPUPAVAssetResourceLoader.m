//
//  VPUPAVAssetResourceLoader.m
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPAVAssetResourceLoader.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "VPUPVideoRequestTask.h"
#import "NSURL+VPUPPlayer.h"
#import "VPUPFileHandle.h"
#import "VPUPTrafficStatistics.h"

@interface VPUPAVAssetResourceLoader ()<VPUPVideoRequestTaskDelegate>

@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *tempVideoPath;

@end

@implementation VPUPAVAssetResourceLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        _pendingRequests = [NSMutableArray array];
    }
    return self;
}

- (NSString *)tempVideoPath {
    if (!_tempVideoPath) {
        _tempVideoPath = [VPUPFileHandle tempFilePathWithURL:[self.url vpup_originalSchemeURL]];
    }
    return _tempVideoPath;
}

- (NSString *)videoPath {
    if (!_videoPath) {
        _videoPath = [VPUPFileHandle filePathWithURL:[self.url vpup_originalSchemeURL]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_videoPath]) {
            [VPUPFileHandle saveOrUpdateCacheFile:_videoPath];
        }
    }
    return _videoPath;
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest {
    
    NSString *mimeType = nil;
    long long contentLength = 0;
    
    if (self.videoPath && [[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        mimeType = @"video/mp4";
        NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
        contentLength = filedata.length;
    }
    else
    {
        mimeType = self.task.mimeType;
        contentLength = self.task.fileLength;
    }
    
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = contentLength;
}

#pragma mark - AVURLAsset resource loader methods

- (void)processPendingRequests {
    
    NSMutableArray *requestsCompleted = [NSMutableArray array];  //请求完成的数组
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        [self fillInContentInformation:loadingRequest.contentInformationRequest]; //对每次请求加上长度，文件类型等信息
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest]; //判断此次请求的数据是否处理完全
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];  //如果完整，把此次请求放进 请求完成的数组
            [loadingRequest finishLoading];
        }
    }
    
    [self.pendingRequests removeObjectsInArray:requestsCompleted];   //在所有请求的数组中移除已经完成的
}


- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    //NSLog(@"%lld,%ld",startOffset,dataRequest.requestedLength);
    
    //有本地缓存文件，使用本地缓存文件
    if (self.videoPath && [[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
        @try {
            [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset, (NSUInteger)dataRequest.requestedLength)]];
        } @catch (NSException *exception) {
            
        }
        return YES;
    }
    
    if ((self.task.offset + self.task.cacheLength) < startOffset)
    {
        //NSLog(@"NO DATA FOR REQUEST");
        return NO;
    }
    
    if (startOffset < self.task.offset) {
        return NO;
    }
    
    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.tempVideoPath] options:NSDataReadingMappedIfSafe error:nil];
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = filedata.length - ((NSInteger)startOffset - self.task.offset);
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset- self.task.offset, (NSUInteger)numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = (self.task.offset + self.task.cacheLength) >= endOffset;
    
    return didRespondFully;
}


/**
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求， 需要为每一次请求作出处理
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 *
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.pendingRequests addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
    //NSLog(@"----%@", loadingRequest);
    
    if (self.videoPath && [[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        [self performSelector:@selector(processPendingRequests) withObject:nil afterDelay:0.5];
    }
    return YES;
}


- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    if (!_url && ![_url isEqual:[loadingRequest.request URL]]) {
        self.url = [loadingRequest.request URL];
        _videoPath = nil;
        _tempVideoPath = nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        
        [self processPendingRequests];
        VPUPVideoRequestTask *task = [[VPUPVideoRequestTask alloc] init];
        task.isFinishLoad = YES;
        if ([self.delegate respondsToSelector:@selector(didCompleteWithLoader:)]) {
            [self.delegate didCompleteWithLoader:self];
        }
        return;
    }
    
    if (self.task) {
        if (loadingRequest.dataRequest.requestedOffset >= self.task.offset &&
            loadingRequest.dataRequest.requestedOffset <= self.task.offset + self.task.cacheLength) {
            //数据已经缓存，则直接完成
            NSLog(@"数据已经缓存，则直接完成");
            [self processPendingRequests];
        }else {
            //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
            if (self.seekRequired) {
                NSLog(@"Seek操作，则重新请求");
                [self newTaskWithLoadingRequest:loadingRequest cache:NO];
            }
        }
    }else {
        //新建 发送流量统计
        VPUPTrafficStatisticsList *list = [[VPUPTrafficStatisticsList alloc] init];
        [list addTrafficNoSizeByName:[[_videoPath componentsSeparatedByString:@"/"] lastObject] fileUrl:[self.url absoluteString]];
        [VPUPTrafficStatistics sendTrafficeStatistics:list type:VPUPTrafficTypeRealTime];
        
        [self newTaskWithLoadingRequest:loadingRequest cache:YES];
    }
    
    
//    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);
//
//    if (self.task.cacheLength > 0) {
//        [self processPendingRequests];
//    }
//
//    if (!self.task) {
//        self.task = [[VPUPVideoRequestTask alloc] init];
////        self.task.tempPath = _tempVideoPath;
////        self.task.videoPath = _videoPath;
//        self.task.delegate = self;
//        [self.task setUrl:interceptedURL offset:0];
//    } else {
//        // 如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
//        if (self.task.offset + self.task.cacheLength + 1024 * 300 < range.location ||
//            // 如果往回拖也重新请求
//            range.location < self.task.offset) {
//            [self.task setUrl:interceptedURL offset:range.location];
//        }
//    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cache:(BOOL)cache {
    NSUInteger fileLength = 0;
    if (self.task) {
        fileLength = self.task.fileLength;
        [self.task cancel];
    }
    self.task = [[VPUPVideoRequestTask alloc]init];
    self.task.url = self.url;
    self.task.offset = loadingRequest.dataRequest.requestedOffset;
    self.task.cacheFile = cache;
    if (fileLength > 0) {
        self.task.fileLength = fileLength;
    }
    self.task.delegate = self;
    [self.task start];
    self.seekRequired = NO;
}


- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - VPUPVideoRequestTaskDelegate

- (void)didReceiveVideoDataWithTask:(VPUPVideoRequestTask *)task {
    [self processPendingRequests];
}

- (void)didFinishLoadingWithTask:(VPUPVideoRequestTask *)task {
    if ([self.delegate respondsToSelector:@selector(didCompleteWithLoader:)]) {
        [self.delegate didCompleteWithLoader:self];
    }
}

- (void)didFailLoadingWithTask:(VPUPVideoRequestTask *)task error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didFailedWithLoader:error:)]) {
        [self.delegate didFailedWithLoader:self error:error];
    }
}

@end
