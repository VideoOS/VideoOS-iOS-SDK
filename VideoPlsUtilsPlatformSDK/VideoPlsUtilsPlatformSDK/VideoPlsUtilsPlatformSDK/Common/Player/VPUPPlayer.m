//
//  VPUPPlayer.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/10/27.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "VPUPVideo.h"
#import "VPUPAVAssetResourceLoader.h"
#import "NSURL+VPUPPlayer.h"

@interface VPUPPlayer () <VPUPAVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSArray *videoArray;

@property (nonatomic, strong) AVPlayer                  *player;
@property (nonatomic, strong) AVPlayerLayer             *playerLayer;
@property (nonatomic, strong) UITapGestureRecognizer    *videoTapGesture;

@property (nonatomic, assign) VPUPPlayerStatus          status;
@property (nonatomic, assign) CMTime                    currentTime;

@property (nonatomic, strong) id                        timeObserver;
@property (nonatomic, strong) VPUPAVAssetResourceLoader *resouerLoader;

@end

@implementation VPUPPlayer

#pragma mark - public function

- (instancetype)initWithFrame:(CGRect)frame video:(VPUPVideo *)video {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentTime = kCMTimeZero;
        self.video = video;
        [self loadPlayerWithUrl:video.url];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapGesture:)];
        [self addGestureRecognizer:tapGesture];

        
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
    self.playerLayer.frame = frame;
}

- (void)updateCurrentPlayerVolume:(CGFloat)volume {
    _player.volume = volume;
}

- (NSTimeInterval)currentPlayerItemTime {
    return CMTimeGetSeconds(_player.currentItem.currentTime);
}

- (NSTimeInterval)currentPlayerItemDuration {
    return CMTimeGetSeconds(_player.currentItem.duration);
}

- (void)play {
    
    if (CMTimeCompare(self.currentTime, kCMTimeZero) == 0) {
        [self.player play];
        self.status = VPUPPlayerStatusPlaying;
        return;
    }
    
    @try {
        __weak typeof(self) weakSelf = self;
        [_player seekToTime:self.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (!weakSelf) {
                return;
            }
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (finished) {
                [strongSelf.player play];
                strongSelf.status = VPUPPlayerStatusPlaying;
            }
        }];
    } @catch (NSException *exception) {
        [self.player play];
        self.status = VPUPPlayerStatusPlaying;
    }
    
}

- (void)pause {
    [_player pause];
    self.status = VPUPPlayerStatusPaused;
    self.currentTime = _player.currentItem.currentTime;
}

- (void)stop {
    
    [_player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [_player removeTimeObserver:_timeObserver];
    [_player pause];
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [_player replaceCurrentItemWithPlayerItem:nil];
    
    [_playerLayer removeFromSuperlayer];
    _playerLayer.player = nil;
    _playerLayer = nil;
    [self removeGestureRecognizer:_videoTapGesture];
    self.player = nil;
}

#pragma mark - private function


- (void)playerTapGesture:(UITapGestureRecognizer *)tapGesture {
    
    if ([self.playerDelegate respondsToSelector:@selector(player:didClicked:)]) {
        [self.playerDelegate player:self didClicked:self.video.url];
    }
    
}
- (void)loadPlayerWithUrl:(NSURL *)url {
    
    _player = [[AVPlayer alloc] init];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [_playerLayer setFrame:self.frame];
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    [self prepareToPlayWithUrl:url];
}

- (void)prepareToPlayWithUrl:(NSURL *)url {

    self.resouerLoader = [[VPUPAVAssetResourceLoader alloc] init];
    self.resouerLoader.delegate = self;
    //必须要替换URL scheme，不然不会执行到resouerLoader
    NSURL *playUrl = [url vpup_customSchemeURL];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
    [asset.resourceLoader setDelegate:self.resouerLoader queue:dispatch_get_main_queue()];
    NSArray *requestdKeys = @[@"playable"];
    __weak typeof(self)weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:requestdKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf didPrepareToPlayAsset:asset withKeys:requestdKeys];
        });
    }];
}

- (void)didPrepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    
    for (NSString *thisKey in requestedKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed || keyStatus == AVPlayerLooperStatusCancelled) {
            [self loadError:error];
            return;
        }
    }
    
    if (!asset.playable) {
        [self loadError:nil];
        return;
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [_player replaceCurrentItemWithPlayerItem:item];
    [self addPlayerObserver];
}

- (void)addPlayerObserver {
    
    __weak typeof(self) weakSelf = self;
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3) queue:NULL usingBlock:^(CMTime time) {
        
        if (!weakSelf) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        CMTime current = strongSelf.player.currentItem.currentTime;
        CMTime duration = strongSelf.player.currentItem.duration;
       
        if ([strongSelf.playerDelegate respondsToSelector:@selector(player:playedTime:totalTime:)]) {
            [strongSelf.playerDelegate player:strongSelf playedTime:((double)current.value/current.timescale) totalTime:((double)duration.value/duration.timescale)];
        }
        
        double margin = ((double)duration.value/duration.timescale) - ((double)current.value/current.timescale);
        
        if (strongSelf.video.ex > 0 && strongSelf.video.ex < ((double)current.value/current.timescale)) {
            [strongSelf playbackFinished];
        }
        
        if (margin <= 0.5 && margin > 0) {
            [strongSelf playbackFinished];
        }

        
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (!self) {
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerItemStatusFailed:
                
                break;
                
            case AVPlayerItemStatusUnknown:
                
                break;
                
            case AVPlayerItemStatusReadyToPlay:
                self.status = VPUPPlayerStatusPrepareToPlay;
                if ([self.playerDelegate respondsToSelector:@selector(playerPrepareToPlay:)]) {
                    [self.playerDelegate playerPrepareToPlay:self];
                }
                
                break;
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        BOOL playbackBufferEmpty = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (playbackBufferEmpty) {
            self.status = VPUPPlayerStatusPlaybackBufferEmpty;
        }
        NSLog(@"VPUPPlayer playbackBufferEmpty %d",playbackBufferEmpty);
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playbackLikelyToKeepUp = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (playbackLikelyToKeepUp) {
            self.status = VPUPPlayerStatusPlaybackLikelyToKeepUp;
        }
        NSLog(@"VPUPPlayer playbackLikelyToKeepUp %d",playbackLikelyToKeepUp);
    }
}

- (void)playbackFinished {
    
    [self stop];
    self.status = VPUPPlayerStatusPlayCompleted;
    if ([self.playerDelegate respondsToSelector:@selector(playerPlaybackFinished:)]) {
        [self.playerDelegate playerPlaybackFinished:self];
    }
}

- (void)loadError:(NSError *)error {
    self.status = VPUPPlayerStatusError;
    if ([self.playerDelegate respondsToSelector:@selector(player:loadError:)]) {
        [self.playerDelegate player:self loadError:error];
    }
}

- (void)dealloc {
    
}

- (void)didCompleteWithLoader:(VPUPAVAssetResourceLoader *)loader {
    
}

- (void)didFailedWithLoader:(VPUPAVAssetResourceLoader *)loader error:(NSError *)error {
    [self loadError:error];
}

@end
