//
//  VPUPPlayer.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/10/27.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VPUPVideo;
@protocol VPUPPlayerDelegate;


typedef NS_ENUM(NSInteger, VPUPPlayerStatus) {
    VPUPPlayerStatusError = -1,
    VPUPPlayerStatusCreate,
    VPUPPlayerStatusPreparing,
    VPUPPlayerStatusPrepareToPlay,
    VPUPPlayerStatusPlaying,
    VPUPPlayerStatusPaused,
    VPUPPlayerStatusPlaybackBufferEmpty,
    VPUPPlayerStatusPlaybackLikelyToKeepUp,
    VPUPPlayerStatusPlayCompleted,
};


@interface VPUPPlayer : UIView

@property (nonatomic, weak) id<VPUPPlayerDelegate>playerDelegate;

@property (nonatomic, strong) VPUPVideo *video;

@property (nonatomic, readonly) VPUPPlayerStatus status;

@property (nonatomic, readonly) NSTimeInterval currentPlayerItemTime;

@property (nonatomic, readonly) NSTimeInterval currentPlayerItemDuration;

- (instancetype)initWithFrame:(CGRect)frame video:(VPUPVideo *)video;

- (void)updateFrame:(CGRect)frame;

- (void)updateCurrentPlayerVolume:(CGFloat)volume;

- (void)play;

- (void)pause;

- (void)stop;

@end

@protocol VPUPPlayerDelegate <NSObject>

- (void)playerPrepareToPlay:(VPUPPlayer *)player;

- (void)playerPlaybackFinished:(VPUPPlayer *)player;

- (void)player:(VPUPPlayer *)player loadError:(NSError *)error;

- (void)player:(VPUPPlayer *)player playedTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)player:(VPUPPlayer *)player didClicked:(NSURL *)url;

@end



