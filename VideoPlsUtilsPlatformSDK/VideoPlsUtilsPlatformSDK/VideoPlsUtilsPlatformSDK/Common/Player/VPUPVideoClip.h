//
//  VPUPVideoClip.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/10/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPUPPlayer.h"
@class VPUPVideo;
@protocol VPUPVideoClipProtocol;

@interface VPUPVideoClip : UIView

@property (nonatomic, weak) id<VPUPVideoClipProtocol>delegate;
@property (nonatomic, copy) NSArray<VPUPVideo *> *videoArray;
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, readonly) VPUPPlayerStatus status;
@property (nonatomic, readonly) NSTimeInterval currentPlayerItemTime;
@property (nonatomic, readonly) NSTimeInterval currentPlayerItemDuration;

- (instancetype)initWithFrame:(CGRect)frame volume:(CGFloat)volume videoArray:(NSArray<VPUPVideo *> *)videoArray;

- (void)updateFrame:(CGRect)frame;

- (void)updateCurrentPlayerVolume:(CGFloat)volume;

- (void)play;

- (void)pause;

- (BOOL)videoClipIsPlaying;

@end


@protocol VPUPVideoClipProtocol <NSObject>

- (void)videoClipVideoPreparePlaying:(NSUInteger)index videoUrl:(NSURL *)url;

- (void)videoClipVideoStartPlaying:(NSUInteger)index videoUrl:(NSURL *)url;

- (void)videoClipVideoFinished:(NSUInteger)index videoUrl:(NSURL *)url;

- (void)videoClipAllFinished;

- (void)videoClipDidClick:(NSUInteger)index videoUrl:(NSURL *)url;

- (void)videoClipCurrentVideoIndex:(NSUInteger)index url:(NSURL *)url timePlayed:(NSTimeInterval)timePlayed totalTime:(NSTimeInterval)totalTime;

- (void)videoClipDidLoadError:(NSError *)error;

@end

