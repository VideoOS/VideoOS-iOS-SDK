//
//  VPUPResumeDownloader.h
//  ResumeDownloader
//
//  Created by peter on 09/11/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPUPResumeDownloader;

@protocol VPUPResumeDownloaderDelegate <NSObject>
@optional

- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location;
- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
- (void)VPUPResumeDownloader:(VPUPResumeDownloader *)downloader didCompleteWithError:(NSError *)error;

@end



@interface VPUPResumeDownloader : NSObject

@property (nonatomic, readonly) NSString* downloadUrl;
@property (nonatomic, readonly) NSString* resumePath;
@property (nonatomic, weak) id <VPUPResumeDownloaderDelegate> delegate;
@property (nonatomic, assign) BOOL isForceDownload;
@property (nonatomic, readonly) NSProgress *progress;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl resumePath:(NSString*)resumePath;

- (instancetype)initWithDownloadUrl:(NSString*)downloadUrl
                         resumePath:(NSString*)resumePath
                           progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                  completionHandler:(void (^)(VPUPResumeDownloader *downloader, NSURL *filePath, NSError *error))completionHandler;


- (void)resume;
- (void)suspend;
- (void)cancel;

- (void)invalidate;

@end
