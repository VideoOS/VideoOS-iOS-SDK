//
//  VPAVPlayerController.m
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPAVPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "PrivateConfig.h"

NSString *const VPAVPlayerIsPreparedToPlayNotification = @"VPAVPlayerIsPreparedToPlayNotification";
NSString *const VPAVPlayerLoadStateDidChangeNotification = @"VPAVPlayerLoadStateDidChangeNotification";
NSString *const VPAVPlayerPlaybackDidFinishNotification = @"VPAVPlayerPlaybackDidFinishNotification";
NSString *const VPAVPlayerPlaybackStateDidChangeNotification = @"VPAVPlayerPlaybackStateDidChangeNotification";
NSString *const VPAVPlayerPlayerbackDidSeekCompleteNotification = @"VPAVPlayerPlayerbackDidSeekCompleteNotification";

static NSString *kErrorDomain = @"VPAVPlayerController";
//buffer progress max milliseconds
static const float kMaxHighWaterMarkMilli = 5 * 1000;

@interface VPAVPlayerController()

@property (nonatomic, readwrite) UIView *view;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@property (nonatomic, assign, readwrite) NSTimeInterval playableDuration;
@property (nonatomic, assign, readwrite) NSInteger bufferingProgress;

@property (nonatomic, readwrite) CGSize videoRect;
@property (nonatomic, readwrite) CGRect videoNowRect;

@property (nonatomic, assign) BOOL isPreparedToPlay;

@end


@implementation VPAVPlayerController {
    NSURL           *_playUrl;
    AVURLAsset      *_playAsset;
    AVPlayerItem    *_playerItem;
    AVPlayer        *_player;
    AVPlayerLayer   *_playerLayer;
    
    MPMoviePlaybackState _playbackState;
    MPMovieLoadState _loadState;
    
    CGFloat _videoWidth;
    CGFloat _videoHeight;
    
    CGRect _viewFrame;
    
    BOOL _isM3U8;
    BOOL _isError;
    BOOL _isCompleted;
    BOOL _isPrerolling;
    BOOL _isSeeking;
    
    BOOL _isStop;
    BOOL _isStartPlay;

}

@synthesize view                = _view;
@synthesize duration            = _duration;
@synthesize playableDuration    = _playableDuration;
@synthesize bufferingProgress   = _bufferingProgress;
@synthesize videoTrueSize       = _videoTrueSize;
@synthesize videoNowRect        = _videoNowRect;


- (instancetype)init {
    self = [super init];
    if(self) {
        [self initPlayer];
    }
    return self;
}

- (instancetype)initWithContentURLString:(NSString *)urlString {
    self = [self init];
    if(self) {
        [self setContentURLString:urlString];
    }
    return self;
}

- (void)setContentURLString:(NSString *)urlString {
    if(urlString) {
        
        if ([PrivateConfig shareConfig].unlimitedPlay) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"zelear.mp4" ofType:nil];
            _playUrl = [NSURL fileURLWithPath:path];
            return;
        }
        
        _playUrl = [NSURL URLWithString:urlString];
    }
}

- (void)changeContentURLString:(NSString *)urlString {
    if (!_player) {
        return;
    }
    
    if (_playerItem != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_playerItem cancelPendingSeeks];
            [self removeItemObserver];
            [self deregisterPlayerNotification];
        });
    }
    [self setContentURLString:urlString];
    _isPreparedToPlay = NO;
    [self prepareToPlay];
}

- (void)initPlayer {
    _player = [[AVPlayer alloc] init];
    [_player setAllowsExternalPlayback:NO];
    
    _view = [[UIView alloc] initWithFrame:_viewFrame];
    
    _playerLayer = [[AVPlayerLayer alloc] init];
    [_playerLayer setFrame:_view.bounds];
    [_playerLayer setBackgroundColor:[UIColor blackColor].CGColor];
    
    [_view.layer insertSublayer:_playerLayer atIndex:0];
    
    [self setScreenOn:YES];
}

- (void)setScreenOn:(BOOL)on {
    [UIApplication sharedApplication].idleTimerDisabled = on;
}

- (void)dealloc {
    [self shutdown];
}

- (void)prepareToPlay {
    if(!_player) {
        return;
    }
    
    if(!_playUrl) {
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:_playUrl];
    NSArray *requestedKeys = @[@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [self didPrepareToPlayAsset:asset withKeys:requestedKeys];
       });
    }];
}

- (void)play
{
    if(!_player) {
        return;
    }
    if (_isCompleted)
    {
        _isCompleted = NO;
        [_player seekToTime:kCMTimeZero];
    }
    
    [_player play];
    
    if (!_isStartPlay) {
        _isStartPlay = YES;
        if (self.videoPlayerDelagate&&[self.videoPlayerDelagate respondsToSelector:@selector(videoPlayerDidStartVideo)]) {
            [self.videoPlayerDelagate videoPlayerDidStartVideo];
        }
    }
    
    if (self.videoPlayerDelagate&&[self.videoPlayerDelagate respondsToSelector:@selector(videoPlayerDidPlayVideo)]) {
        [self.videoPlayerDelagate videoPlayerDidPlayVideo];
    }
}

- (void)pause
{
    if(!_player) {
        return;
    }
    _isPrerolling = NO;
    [_player pause];
    if (self.videoPlayerDelagate&&[self.videoPlayerDelagate respondsToSelector:@selector(videoPlayerDidPauseVideo)]) {
        [self.videoPlayerDelagate videoPlayerDidPauseVideo];
    }
}

- (void)stop
{
    if(!_player) {
        return;
    }
    [_player pause];
    _isCompleted = YES;
    if (self.videoPlayerDelagate&&[self.videoPlayerDelagate respondsToSelector:@selector(videoPlayerDidStopVideo)]) {
        [self.videoPlayerDelagate videoPlayerDidStopVideo];
    }
}

- (BOOL)isPlaying
{
    if(!_player) {
        return NO;
    }
    if (_player.rate >= 0.0001f) {
        return YES;
    } else {
        if (_isPrerolling) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)shutdown
{
    _isStop = YES;
    
    if(!_player) {
        return;
    }
    [self stop];
    
    if (_playerItem != nil) {
        [_playerItem cancelPendingSeeks];
    }
    
    [self removeItemObserver];
    [self deregisterPlayerNotification];
    
    [_player replaceCurrentItemWithPlayerItem:nil];
    [_playerLayer removeAllAnimations];
    [_playerLayer removeFromSuperlayer];
    _player = nil;
    _playerItem = nil;
    _playAsset = nil;
    _playUrl = nil;
    
    self.view = nil;
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    if (!_player)
        return;
    
    _isSeeking = YES;
    
    [self didPlaybackStateChange];
    [self didLoadStateChange];
    
    [_player pause];
    [_player seekToTime:CMTimeMakeWithSeconds(currentPlaybackTime, NSEC_PER_SEC)
      completionHandler:^(BOOL finished) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [[NSNotificationCenter defaultCenter] postNotificationName:VPAVPlayerPlayerbackDidSeekCompleteNotification object:self];
              _isSeeking = NO;
              [_player play];
              
              [self didPlaybackStateChange];
              [self didLoadStateChange];
          });
      }];
}

- (void)updateFrame:(CGRect)newFrame {
    [_playerLayer removeAllAnimations];
    
    [self.view setFrame:newFrame];
    
    //用来移除CALayer自带动画, 在没有动画的时候
    if([[self.view superview].layer.animationKeys count] == 0) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [_playerLayer setFrame:self.view.bounds];
        [CATransaction commit];
    }
    else {
        [CATransaction begin];
        CAAnimation *anim = [[self.view superview].layer animationForKey:@"position"];
        [CATransaction setAnimationDuration:anim.duration * 1.4f];
        [_playerLayer setFrame:self.view.bounds];
        [CATransaction commit];
    }
    
    _viewFrame = newFrame;
    [self calcVideoRect];
}

- (NSTimeInterval)currentPlaybackTime {
    if(!_player) {
        return 0.0f;
    }
    
    return CMTimeGetSeconds([_player currentTime]);
}

- (NSTimeInterval)currentItemDuration {
    if (!_player) {
        return 0.0f;
    }
    return CMTimeGetSeconds(_player.currentItem.duration);
}

- (MPMovieLoadState)loadState
{
    if (_player == nil)
        return MPMovieLoadStateUnknown;
    
    if (_isSeeking)
        return MPMovieLoadStateStalled;
    
    AVPlayerItem *playerItem = _playerItem;
    if (playerItem == nil)
        return MPMovieLoadStateUnknown;
    
    if (_player != nil && _player.rate > 0.0001f) {
        return MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK;
    } else if ([playerItem isPlaybackBufferFull]) {
        return MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK;
    } else if ([playerItem isPlaybackLikelyToKeepUp]) {
        return MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK;
    } else if ([playerItem isPlaybackBufferEmpty]) {
        return MPMovieLoadStateStalled;
    } else {
        return MPMovieLoadStateUnknown;
    }
}

- (MPMoviePlaybackState)playbackState
{
    if (!_player)
        return MPMoviePlaybackStateStopped;
    
    MPMoviePlaybackState mpState = MPMoviePlaybackStateStopped;
    if (_isCompleted) {
        mpState = MPMoviePlaybackStateStopped;
    } else if (_isSeeking) {
        mpState = MPMoviePlaybackStateSeekingForward;
    } else if ([self isPlaying]) {
        mpState = MPMoviePlaybackStatePlaying;
    } else {
        mpState = MPMoviePlaybackStatePaused;
    }
    return mpState;
}

- (void)didPrepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    if (_isStop) {
        [self shutdown];
        return;
    }
    
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            _isError = YES;
            [self assetFailedToPrepareForPlayback:error];
            return;
        } else if (keyStatus == AVKeyValueStatusCancelled) {
            _isError = YES;
            error = [NSError errorWithDomain:kErrorDomain code:1001 userInfo:@{@"reason":@"AVKeyValueStatusCancelled"}];
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable)
    {
        NSError *error = [NSError errorWithDomain:@"AVPlayer"
                                             code:0
                                         userInfo:nil];
        _isError = YES;
        [self assetFailedToPrepareForPlayback:error];
        return;
    }
    
    NSArray *tracksArray = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if([tracksArray count] != 0) {
        AVAssetTrack *track = [tracksArray firstObject];
        
        _videoWidth = track.naturalSize.width;
        _videoHeight = track.naturalSize.height;
        
        _videoTrueSize = CGSizeMake(_videoWidth, _videoHeight);
        [self calcVideoRect];
    }
    else {
        //Cannot get any tracks, probably be m3u8
        _isM3U8 = YES;
        _videoWidth = -1;
        _videoHeight = -1;
        
        _videoTrueSize = CGSizeMake(_videoWidth, _videoHeight);
    }
    
    _playAsset = asset;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_playAsset];
    
    _playerItem = playerItem;
    
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
    
    [self addItemObserver];
    [self registerPlayerNotification];
    
}

- (void)didPlayableDurationUpdate
{
    NSTimeInterval currentPlaybackTime = self.currentPlaybackTime;
    int playableDurationMilli    = (int)(self.playableDuration * 1000);
    int currentPlaybackTimeMilli = (int)(currentPlaybackTime * 1000);
    
    int bufferedDurationMilli = playableDurationMilli - currentPlaybackTimeMilli;
    if (bufferedDurationMilli > 0) {
        self.bufferingProgress = bufferedDurationMilli * 100 / kMaxHighWaterMarkMilli;
        
        if (self.bufferingProgress > 100) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.bufferingProgress > 100) {
                    if ([self isPlaying]) {
                        _player.rate = 1.0f;
                    }
                }
            });
        }
        
    }
}

- (void)didPlaybackStateChange
{
    if (_playbackState != self.playbackState) {
        _playbackState = self.playbackState;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:VPAVPlayerPlaybackStateDidChangeNotification
         object:self];
    }
    
}

- (void)didLoadStateChange
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:VPAVPlayerLoadStateDidChangeNotification
     object:self];
}

- (void)onError:(NSError *)error
{
    _isError = YES;
    __block NSError *blockError = error;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didPlaybackStateChange];
        [self didLoadStateChange];
        
        if (blockError == nil) {
            blockError = [[NSError alloc] init];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:VPAVPlayerPlaybackDidFinishNotification
         object:self
         userInfo:@{
                    MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: @(MPMovieFinishReasonPlaybackError),
                    @"error": blockError
                    }];
    });
}

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self onError:error];
}

- (void)playerItemFailedToPlayToEndTime:(NSNotification *)notification
{
    [self onError:[notification.userInfo objectForKey:@"error"]];
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    _isCompleted = YES;
    
    if (self.videoPlayerDelagate&&[self.videoPlayerDelagate respondsToSelector:@selector(videoPlayerDidStopVideo)]) {
        [self.videoPlayerDelagate videoPlayerDidStopVideo];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self didPlaybackStateChange];
//        [self didLoadStateChange];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:VPAVPlayerPlaybackDidFinishNotification
         object:self
         userInfo:@{
                    MPMoviePlayerPlaybackDidFinishReasonUserInfoKey: @(MPMovieFinishReasonPlaybackEnded)
                    }];
    });
}

- (void)calcVideoRect {
    if(_videoWidth == 0 || _videoHeight == 0) {
        return;
    }
    
    CGFloat videoRatio = 1.0f * _videoWidth / _videoHeight;
    
    CGFloat viewWidth = _viewFrame.size.width;
    CGFloat viewHeight = _viewFrame.size.height;
    
    if(viewWidth == 0 || viewHeight == 0) {
        viewWidth = [UIScreen mainScreen].bounds.size.width;
        viewHeight = [UIScreen mainScreen].bounds.size.height;
    }
    
    CGFloat screenRatio = 1.0f * viewWidth / viewHeight;
    
    if(videoRatio >= screenRatio) {
        _videoNowRect = CGRectMake(0, (viewHeight - viewWidth / videoRatio) / 2, viewWidth, viewWidth / videoRatio);
    }
    else {
        _videoNowRect = CGRectMake((viewWidth - viewHeight * videoRatio) / 2, 0, viewHeight * videoRatio, viewHeight);
    }
}

- (NSTimeInterval)availableItemDuration:(AVPlayerItem *)item {
    NSArray *loadedTimeRanges = [item loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)addItemObserver {
    @try {
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRange" options:NSKeyValueObservingOptionNew context:nil];
    } @catch (NSException *exception) {
        
    }
}

- (void)removeItemObserver {
    @try {
        [_playerItem removeObserver:self forKeyPath:@"status" context:nil];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRange" context:nil];
    } @catch (NSException *exception) {
        
    }
}

- (void)registerPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
}

- (void)deregisterPlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerItemStatusUnknown: {
            
                break;
            }
            case AVPlayerItemStatusReadyToPlay: {
                if(_isPreparedToPlay) {
                    return;
                }
                [_playerLayer setPlayer:_player];
                
                self.isPreparedToPlay = YES;
                
                if(_isM3U8) {
                    CGSize videoSize = [_player currentItem].presentationSize;
                    
                    _videoWidth = videoSize.width;
                    _videoHeight = videoSize.height;
                    
                    _videoTrueSize = CGSizeMake(_videoWidth, _videoHeight);
                    [self calcVideoRect];
                }
                
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                NSTimeInterval duration = CMTimeGetSeconds(playerItem.duration);
                if (duration <= 0) {
                    self.duration = 0.0f;
                }
                else {
                    self.duration = duration;
                }
                _isStartPlay = false;
                [[NSNotificationCenter defaultCenter] postNotificationName:VPAVPlayerIsPreparedToPlayNotification
                 object:self];
            
//                [self play];
                
                break;
            }
            case AVPlayerItemStatusFailed: {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
        
        [self didPlaybackStateChange];
        [self didLoadStateChange];
    }
    else if([keyPath isEqualToString:@"loadedTimeRange"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if(_player && playerItem.status == AVPlayerItemStatusReadyToPlay) {
            NSTimeInterval availableTimeInterval = [self availableItemDuration:playerItem];
            if(!isnan(availableTimeInterval) && availableTimeInterval > 0) {
                self.playableDuration = availableTimeInterval;
                [self didPlayableDurationUpdate];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



@end
