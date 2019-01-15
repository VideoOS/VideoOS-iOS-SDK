//
//  VPUPVideoRequestTask.h
//  ResourceLoader
//
//  Created by peter on 2018/5/4.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define RequestTimeout 15.0

@class VPUPVideoRequestTask;
@protocol VPUPVideoRequestTaskDelegate <NSObject>

- (void)didReceiveVideoDataWithTask:(VPUPVideoRequestTask *)task;
- (void)didFinishLoadingWithTask:(VPUPVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(VPUPVideoRequestTask *)task error:(NSError *)error;

@end

@interface VPUPVideoRequestTask : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger fileLength;
@property (nonatomic, assign, readonly) NSUInteger cacheLength;
@property (nonatomic, strong, readonly) NSString *mimeType;
@property (nonatomic, assign) BOOL isFinishLoad;
@property (nonatomic, assign) BOOL cacheFile;

@property (nonatomic, weak) id <VPUPVideoRequestTaskDelegate> delegate;

- (void)start;

- (void)cancel;

- (void)continueLoading;

- (void)clearData;

@end
