//
//  VPMediaControlView.m
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPMediaControlView.h"
#import "VPMediaMoreButtonView.h"

@interface VPMediaControlView ()

@property (nonatomic, strong) VPMediaMoreButtonView *moreButtonView;



@end

@implementation VPMediaControlView {
    __weak VPAVPlayerController *_player;
    
    BOOL _isFirstPlay;
    
    BOOL _isSeeking;
    BOOL _isLongTime;
    BOOL _isComplete;
    
    BOOL _isShowed;
    
    NSTimer *_refreshTimer;
    
    void (^backButtonActionBlock)(void);

}

@synthesize isShowed = _isShowed;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)mediaControlViewWithNib {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"VPMediaControlView" owner:nil options:nil];
    VPMediaControlView *mediaControlView = [nibViews objectAtIndex:0];
    return mediaControlView;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initMediaControlView];
    }
    return self;
}

- (void)setAVPlayerController:(VPAVPlayerController *)player {
    _player = player;
    [self registerPlayerNotification];
}

- (void)setBackButtonTappedToDo:(void (^)(void))excuteBlock {
    if(excuteBlock) {
        backButtonActionBlock = excuteBlock;
    }
}

- (void)initMediaControlView {
    
    
    [self registerApplicationNotification];
}

- (void)initMoreButtonView {
    if (!_moreButtonView) {
        _moreButtonView = [VPMediaMoreButtonView mediaMoreButtonWithNib];
        _moreButtonView.frame = self.bounds;
        _moreButtonView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _moreButtonView.hidden = YES;
        [self addSubview:_moreButtonView];
    }
    [_moreButtonView setHidden:NO];
}

- (void)showControlView {
    if(_isShowed) {
        return;
    }
    
    _isShowed = YES;
    
    [self resumeTimer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    _topControlView.alpha = 0;
    _bottomControlView.alpha = 0;
    [_topControlView setHidden:NO];
    [_bottomControlView setHidden:NO];
    [UIView animateWithDuration:0.1f animations:^{
        _topControlView.alpha = 1;
        _bottomControlView.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:5.0f];
    }];
    
}

- (void)hideControlView {
    if(!_isShowed) {
        return;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];

    [UIView animateWithDuration:0.1f animations:^{
        _topControlView.alpha = 0;
        _bottomControlView.alpha = 0;
    } completion:^(BOOL finished) {
        [_topControlView setHidden:YES];
        [_bottomControlView setHidden:YES];
        
        [self pauseTimer];
        
        _isShowed = NO;
    }];
}

- (void)stop {
    [self deregisterPlayerNotification];
    [self deregisterApplicationNotification];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)refreshMediaControl {
    NSTimeInterval duration = [_player duration];
    NSTimeInterval position = [_player currentPlaybackTime];
    
    if(!_isSeeking) {
        _playbackSlider.value = position;
    }
    
    [_timeLabel setText:[NSString stringWithFormat:@"%@/%@",[self convertTime:position], [self convertTime:duration]]];
}

- (void)pauseTimer {
    if(!_refreshTimer) {
        return;
    }
    [_refreshTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    if(!_refreshTimer) {
        return;
    }
    [_refreshTimer setFireDate:[NSDate date]];
}

- (NSString *)convertTime:(CGFloat)second {
    
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:_isLongTime ? @"HH:mm:ss" : @"mm:ss"];
    NSString *showTime = [formatter stringFromDate:currentDate];
    
    return showTime;
}

- (IBAction)backButtonTapped:(id)sender {
    if(backButtonActionBlock) {
        backButtonActionBlock();
    }
}

- (IBAction)playButtonTapped:(id)sender {
    if([_player isPlaying]) {
        [_player pause];
        [_playButton setImage:[UIImage imageNamed:@"button_video_play"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VPIPlayButtonAction" object:nil userInfo:@{@"type":@(0)}];
    }
    else {
        if(_isComplete) {
            _isComplete = NO;
        }
        [_player play];
        [_playButton setImage:[UIImage imageNamed:@"button_video_pause"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VPIPlayButtonAction" object:nil userInfo:@{@"type":@(1)}];
    }
}

#pragma mark slider action
- (IBAction)playbackSliderTouchDown:(id)sender {
    _isSeeking = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
}

- (IBAction)playbackSliderTouchCancel:(id)sender {
    [self playbackSliderTouchUpOutside:sender];
}

- (IBAction)playbackSliderTouchUpInside:(id)sender {
    if(_isComplete) {
        _isSeeking = NO;
        [_playbackSlider setValue:0];
        return;
    }
    
    CGFloat nowValue = _playbackSlider.value;
    [_player setCurrentPlaybackTime:nowValue];
}

- (IBAction)playbackSliderTouchUpOutside:(id)sender {
    _isSeeking = NO;
    
    double value = [_player currentPlaybackTime];
    [_playbackSlider setValue:value animated:NO];
}

- (IBAction)moreButtonDidClicked:(id)sender {
    
    [self initMoreButtonView];
    
}
- (IBAction)switchButtonDidClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(switchVideoNetModeStateOff:)]) {
        [self.delegate switchVideoNetModeStateOff:!sender.selected];
    }
}


//点击穿透
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if(hitView == self) {
        return nil;
    }
    else {
        return hitView;
    }
}

- (void)registerPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIsPreparedToPlay:) name:VPAVPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:VPAVPlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidSeekComplete:) name:VPAVPlayerPlayerbackDidSeekCompleteNotification object:_player];
}

- (void)deregisterPlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPAVPlayerIsPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPAVPlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPAVPlayerPlayerbackDidSeekCompleteNotification object:_player];
}

- (void)registerApplicationNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)deregisterApplicationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark -- Notification
#pragma mark player notification
- (void)playerIsPreparedToPlay:(NSNotification *)notification {
    
    NSTimeInterval duration = [_player duration];
    if(!isnan(duration)) {
        [_playbackSlider setMaximumValue:duration];
    }
    else {
        [_playbackSlider setMaximumValue:0];
    }
    
    _playbackSlider.enabled = YES;
    
    if(duration > 3600) {
        _isLongTime = YES;
        [_timeLabel setFont:[UIFont systemFontOfSize:9]];
    }
    else {
        _isLongTime = NO;
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
    }
    
    [self refreshMediaControl];
    
    if(!_refreshTimer) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshMediaControl) userInfo:nil repeats:YES];
        if(!_isShowed) {
            [self pauseTimer];
        }
    }
    
//    [self playButtonTapped:nil];
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification {
    [_playButton setImage:[UIImage imageNamed:@"button_video_play"] forState:UIControlStateNormal];
    _isComplete = YES;
}

- (void)playerPlaybackDidSeekComplete:(NSNotification *)notification {
    _isSeeking = NO;
}

#pragma mark application notification
- (void)applicationWillResignActive {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([_player isPlaying]) {
            [self playButtonTapped:nil];
        }
    });
}

- (void)applicationDidEnterBackground {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([_player isPlaying]) {
            [self playButtonTapped:nil];
        }
    });
}


@end
