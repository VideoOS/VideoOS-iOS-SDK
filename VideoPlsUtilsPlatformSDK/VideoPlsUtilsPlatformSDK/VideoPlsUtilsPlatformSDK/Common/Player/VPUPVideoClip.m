//
//  VPUPVideoClip.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/10/30.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPVideoClip.h"
#import "VPUPPlayer.h"
#import "VPUPVideo.h"
#import <AVFoundation/AVFoundation.h>

@interface VPUPVideoClip () <VPUPPlayerDelegate>

@property (nonatomic, assign) NSUInteger currentVideoIndex;
@property (nonatomic, strong) VPUPPlayer *playedFinishedPlayer;
@property (nonatomic,   weak) VPUPPlayer *currentPlayer;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation VPUPVideoClip

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame volume:[[AVAudioSession sharedInstance] outputVolume] videoArray:nil];
}


- (instancetype)initWithFrame:(CGRect)frame volume:(CGFloat)volume videoArray:(NSArray<VPUPVideo *> *)videoArray {
    self = [super initWithFrame:frame];
    if (self) {
        _isPlaying = YES;
        _videoArray = [videoArray copy];
        _volume = volume;
        _currentVideoIndex = 0;
        [self loadVideoClipWithIndex:0];
    }
    return self;
}

- (NSTimeInterval)currentPlayerItemTime {
    if (self.currentPlayer) {
        return self.currentPlayer.currentPlayerItemTime;
    }
    return 0.0;
}

- (NSTimeInterval)currentPlayerItemDuration {
    if (self.currentPlayer) {
        return self.currentPlayer.currentPlayerItemDuration;
    }
    return 0.0;
}

- (VPUPPlayerStatus)state {
    if (self.currentPlayer) {
        return self.currentPlayer.status;
    }
    return VPUPPlayerStatusCreate;
}

- (void)setVideoArray:(NSArray<VPUPVideo *> *)array {
    _videoArray = [array copy];
    _currentVideoIndex = 0;
    [self loadVideoClipWithIndex:0];
}

- (void)updateFrame:(CGRect)frame {
    
    self.frame = frame;
    
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[VPUPPlayer class]]) {
            [((VPUPPlayer *)view) updateFrame:frame];
        }
    }
}

- (void)layoutSubviews {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[VPUPPlayer class]]) {
            [((VPUPPlayer *)view) updateFrame:self.bounds];
        }
    }
}

- (void)updateCurrentPlayerVolume:(CGFloat)volume {
    self.volume = volume;
    [_currentPlayer updateCurrentPlayerVolume:volume];
}

- (void)play {
    _isPlaying = YES;
    [_currentPlayer play];
}

- (void)pause {
    _isPlaying = NO;
    [_currentPlayer pause];
}

- (BOOL)videoClipIsPlaying {
    return _isPlaying;
}

- (void)loadVideoClipWithIndex:(NSUInteger)index {
    
    if ([_videoArray count] > index) {
        VPUPPlayer *player = [[VPUPPlayer alloc] initWithFrame:self.frame video:[_videoArray objectAtIndex:index]];
        [player updateCurrentPlayerVolume:self.volume];
        player.playerDelegate = self;
        [self addSubview:player];
        [self sendSubviewToBack:player];
    } else {
        if ([self.delegate respondsToSelector:@selector(videoClipAllFinished)]) {
            [self.delegate videoClipAllFinished];
        }
    }
}

#pragma mark - VPUPPlayerDelegate

- (void)playerPrepareToPlay:(VPUPPlayer *)player {
    _currentPlayer = player;
    if (_playedFinishedPlayer) {
        [_playedFinishedPlayer removeFromSuperview];
        _playedFinishedPlayer = nil;
        _currentVideoIndex++;
    }
    
    if ([self.delegate respondsToSelector:@selector(videoClipVideoPreparePlaying:videoUrl:)]) {
        [self.delegate videoClipVideoPreparePlaying:_currentVideoIndex videoUrl:player.video.url];
    }
    
    if (_isPlaying) {
        [player play];
        
        if ([self.delegate respondsToSelector:@selector(videoClipVideoStartPlaying:videoUrl:)]) {
            [self.delegate videoClipVideoStartPlaying:_currentVideoIndex videoUrl:player.video.url];
        }
    }
}

- (void)playerPlaybackFinished:(VPUPPlayer *)player {
    _playedFinishedPlayer = player;
    _currentPlayer = nil;
    if ([self.delegate respondsToSelector:@selector(videoClipVideoFinished:videoUrl:)]) {
        [self.delegate videoClipVideoFinished:_currentVideoIndex videoUrl:player.video.url];
    }
    // 当前播放停止到下一个视频预加载的工程中，index不增加，直到预加载完成，开始播放时才增加
    [self loadVideoClipWithIndex:(_currentVideoIndex + 1)];
}

- (void)player:(VPUPPlayer *)player loadError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(videoClipDidLoadError:)]) {
        [self.delegate videoClipDidLoadError:error];
    }
}

- (void)player:(VPUPPlayer *)player didClicked:(NSURL *)url {
    
    NSUInteger index = [_videoArray count] > _currentVideoIndex ? _currentVideoIndex : [_videoArray count] - 1;
    
    if ([self.delegate respondsToSelector:@selector(videoClipDidClick:videoUrl:)]) {
        [self.delegate videoClipDidClick:index videoUrl:url];
    }
    
}

- (void)player:(VPUPPlayer *)player playedTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    
    NSUInteger index = [_videoArray count] > _currentVideoIndex ? _currentVideoIndex : [_videoArray count] - 1;

    if ([self.delegate respondsToSelector:@selector(videoClipCurrentVideoIndex:url:timePlayed:totalTime:)]) {
        [self.delegate videoClipCurrentVideoIndex:index url:[_videoArray objectAtIndex:index].url timePlayed:currentTime totalTime:totalTime];
    }
}

- (void)dealloc {
    [_currentPlayer stop];
    [_playedFinishedPlayer stop];
}

@end
