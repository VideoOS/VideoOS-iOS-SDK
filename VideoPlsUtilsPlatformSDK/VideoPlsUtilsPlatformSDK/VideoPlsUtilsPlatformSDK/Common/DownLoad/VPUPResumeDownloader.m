//
//  VPUPResumeDownloader.m
//  ResumeDownloader
//
//  Created by peter on 09/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import "VPUPResumeDownloader.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "VPUPMD5Util.h"
#import "VPUPPathUtil.h"

const int64_t kSaveBytesLength = 1024*1024*5;
const float kCallbackProgressStep = 20.0;
static const NSInteger VPUPResumeDownloaderTimeoutInterval = 30;

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)


typedef void (^VPUPResumeDownloaderProgressBlock)(NSProgress *);
typedef void (^VPUPResumeDownloaderCompletionHandler)(VPUPResumeDownloader *downloader, NSURL *filePath, NSError *error);


static NSMutableDictionary *getResumeDictionary(NSData *data) {
    NSMutableDictionary *iresumeDictionary = nil;
    if (IS_IOS10ORLATER) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
            if (root == nil) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch(NSException *exception) {
            
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
    }
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

@interface VPUPResumeDownloader() <NSURLSessionDownloadDelegate>

@property (nonatomic, readwrite, copy) NSString* downloadUrl;
@property (nonatomic, readwrite, copy) NSString* resumePath;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, copy) NSString *downloadTargetPath;
@property (nonatomic, assign) int64_t currentDownloadBytes;
@property (nonatomic, assign) BOOL isFinishDownloading;
@property (nonatomic, copy) VPUPResumeDownloaderProgressBlock progressBlock;
@property (nonatomic, copy) VPUPResumeDownloaderCompletionHandler completionHandler;
@property (nonatomic, readwrite, strong) NSProgress *progress;
@property (nonatomic, assign) BOOL isSaveStepCancel;

@end

@implementation VPUPResumeDownloader

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
{
    return [self initWithDownloadUrl:downloadUrl resumePath:nil];
}

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl resumePath:(NSString*)resumePath
{
    return [self initWithDownloadUrl:downloadUrl
                          resumePath:resumePath
                            progress:nil
                   completionHandler:nil];
}

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                         resumePath:(NSString*)resumePath
                           progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                  completionHandler:(nullable void (^)(VPUPResumeDownloader *downloader, NSURL *filePath, NSError *error))completionHandler
{
    self = [super init];
    if (self) {
        
        _downloadUrl = downloadUrl;
        _resumePath = resumePath;
        
        self.downloadTargetPath = [self getDownloadTargetPathFromResumePath:resumePath];
        
        self.progressBlock = downloadProgressBlock;
        self.completionHandler = completionHandler;
        
        self.isForceDownload = NO;
        
        self.progress = [[NSProgress alloc] init];
        
        self.timeoutInterval = VPUPResumeDownloaderTimeoutInterval;
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = self.timeoutInterval;
        sessionConfiguration.timeoutIntervalForResource = self.timeoutInterval;
        self.backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                               delegate:self
                                                          delegateQueue:self.operationQueue];
    }
    return self;
}

- (NSString*)getDownloadTargetPathFromResumePath:(NSString*)resumePath
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
    NSString *downloadPath = [VPUPPathUtil pathByPlaceholder:@"download"];
    if (resumePath && [resumePath containsString:NSHomeDirectory()]) {
        downloadPath = resumePath;
    }
    else if (resumePath)
    {
        downloadPath = [NSString stringWithFormat:@"%@/%@",downloadPath,resumePath];
    }
    
    NSString *downloadTargetPath;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    // If targetPath is a directory, use the file name we got from the urlRequest.
    // Make sure downloadTargetPath is always a file, not directory.
    if (isDirectory) {
        NSString *fileName = [request.URL lastPathComponent];
        if (!fileName) {
            fileName = @"temp";
        }
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    return downloadTargetPath;
}

- (NSURLSessionDownloadTask*)createDownloadTask
{
    // AFN use `moveItemAtURL` to move downloaded file to target path,
    // this method aborts the move attempt if a file already exist at the path.
    // So we remove the exist file before we start the download task.
    // https://github.com/AFNetworking/AFNetworking/issues/3775
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.downloadTargetPath]) {
        if (self.isForceDownload)
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.downloadTargetPath error:nil];
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(VPUPResumeDownloader:didFinishDownloadingToURL:)]) {
                [self.delegate VPUPResumeDownloader:self didFinishDownloadingToURL:[NSURL fileURLWithPath:self.downloadTargetPath]];
            }
            else if (self.completionHandler)
            {
                self.completionHandler(self, [NSURL fileURLWithPath:self.downloadTargetPath], nil);
            }
            [self invalidate];
            return nil;
        }
    }
    
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self incompleteDownloadTempPathForDownloadPath:self.downloadUrl].path];

    self.resumeData = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadPath:self.downloadUrl]];
    
    BOOL resumeDataIsValid = [VPUPResumeDownloader validateResumeData:self.resumeData];
    
    BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    
    if (canBeResumed) {
        @try {
            NSMutableDictionary *resumeDictionary = getResumeDictionary(self.resumeData);
            if (resumeDictionary) {
                self.currentDownloadBytes = [[resumeDictionary objectForKey:@"NSURLSessionResumeBytesReceived"] integerValue];
            }
            if ([resumeDictionary objectForKey:@"NSURLSessionResumeByteRange"]) {
                [resumeDictionary removeObjectForKey:@"NSURLSessionResumeByteRange"];
                [resumeDictionary writeToURL:[self incompleteDownloadTempPathForDownloadPath:self.downloadUrl] atomically:YES];
                self.resumeData = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadPath:self.downloadUrl]];
            }
            downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
            self.resumeData = nil;
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            resumeSucceeded = NO;
        }
    }
    if (!resumeSucceeded) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    }
    
    if (!downloadTask)
    {
        NSString *errorStr     = @"Url error";
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : errorStr
                                   };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorUnsupportedURL
                                         userInfo:userInfo];
        [self completeWithFileUrl:nil error:error];
        [self invalidate];
    }
    else
    {
        self.backgroundSession.configuration.timeoutIntervalForRequest = self.timeoutInterval;
        self.backgroundSession.configuration.timeoutIntervalForResource = self.timeoutInterval;
    }
    
    return downloadTask;
}

- (void)resume
{
    if (!self.downloadTask) {
        self.downloadTask = [self createDownloadTask];
    }
    [self.downloadTask resume];
}

- (void)suspend
{
    [self.downloadTask suspend];
}

- (void)cancel
{
    [self cancelBySaveData:NO];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *locationString = [location path];
    if (!self.downloadTargetPath) {
        [self getDownloadTargetPathFromResumePath:self.resumePath];
    }
    
    NSError *error;
    
    if (self.isForceDownload)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.downloadTargetPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.downloadTargetPath error:nil];
        }
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:self.downloadTargetPath error:&error];
    
    if (!error) {
        NSString *filePath = [self incompleteDownloadTempPathForDownloadPath:self.downloadUrl].path;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        self.downloadTask = nil;
        self.resumeData = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(VPUPResumeDownloader:didFinishDownloadingToURL:)]) {
        [self.delegate VPUPResumeDownloader:self didFinishDownloadingToURL:[NSURL fileURLWithPath:self.downloadTargetPath]];
    }
    else if (self.completionHandler)
    {
        self.completionHandler(self, [NSURL fileURLWithPath:self.downloadTargetPath], error);
    }
    self.isFinishDownloading = YES;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    
    if (!self.downloadTask) {
        self.downloadTask = downloadTask;
    }
    
    self.progress.totalUnitCount = totalBytesExpectedToWrite;
    self.progress.completedUnitCount = totalBytesWritten;
    
    if (self.progressBlock)
    {
        self.progressBlock(self.progress);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(VPUPResumeDownloader:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate VPUPResumeDownloader:self
                              didWriteData:bytesWritten
                         totalBytesWritten:totalBytesWritten
                 totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    
    if (totalBytesWritten > self.currentDownloadBytes + kSaveBytesLength) {
        self.currentDownloadBytes = totalBytesWritten;
        [self cancelBySaveData:YES];
    }
}

/*
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的，
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error) {
        if (error.code != NSURLErrorCancelled) {
            if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData])
            {
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                NSURL *localUrl = [self incompleteDownloadTempPathForDownloadPath:self.downloadUrl];
                [resumeData writeToURL:localUrl atomically:YES];
            }
            [self completeWithFileUrl:nil error:error];
        }
        else {
            if (!self.isSaveStepCancel)
            {
                [self completeWithFileUrl:nil error:error];
            }
            else
            {
                self.isSaveStepCancel = NO;
            }
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(VPUPResumeDownloader:didCompleteWithError:)]) {
            [self.delegate VPUPResumeDownloader:self
                           didCompleteWithError:error];
        }
    }
    
    if (self.isFinishDownloading) {
        [self invalidate];
    }
}

- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"VideoPls"];
    }
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [VPUPMD5Util md5HashString:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

+ (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

- (void)cancelBySaveData:(BOOL)isSaveData
{
    self.isSaveStepCancel = isSaveData;
    __weak __typeof(self) weakSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSURL *localUrl = [strongSelf incompleteDownloadTempPathForDownloadPath:strongSelf.downloadUrl];
        [resumeData writeToURL:localUrl atomically:YES];
        strongSelf.downloadTask = nil;
        strongSelf.resumeData = resumeData;
        if (isSaveData) {
            [strongSelf resume];
        }
    }];
}

- (void)completeWithFileUrl:(NSURL *)fileUrl error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(VPUPResumeDownloader:didCompleteWithError:)]) {
        [self.delegate VPUPResumeDownloader:self
                       didCompleteWithError:error];
    }
    else if (self.completionHandler)
    {
        self.completionHandler(self, fileUrl, error);
    }
}

- (void)invalidate
{
    if (self.backgroundSession) {
        [self.backgroundSession invalidateAndCancel];
        self.backgroundSession = nil;
    }
}

@end
