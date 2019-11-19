//
//  DevAppMediaControlView.m
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "DevAppMediaControlView.h"

@interface DevAppMediaControlView () <CAAnimationDelegate>

@end

@implementation DevAppMediaControlView {
    __weak VPAVPlayerController *_player;
    
    BOOL _isFirstPlay;
    
    BOOL _isSeeking;
    BOOL _isLongTime;
    BOOL _isComplete;
    
    BOOL _isShowed;
    
    NSTimer *_refreshTimer;
    
    void (^backButtonActionBlock)(void);
    void (^nextButtonActionBlock)(void);

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
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"DevAppMediaControlView" owner:nil options:nil];
    DevAppMediaControlView *mediaControlView = [nibViews objectAtIndex:0];
    return mediaControlView;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initMediaControlView];
    
    self.switchButton.selected = !self.switchButton.selected;
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

- (void)setNextButtonTappedToDo:(void (^)(void))excuteBlock {
    if(excuteBlock) {
        nextButtonActionBlock = excuteBlock;
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)initMediaControlView {
    
    CAGradientLayer *topGradientLayer = [[CAGradientLayer alloc] init];
    CGRect topFrame = self.topBackView.bounds;
    CGFloat maxWidth = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    topFrame.size.width = maxWidth;
    topGradientLayer.frame = topFrame;
    topGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor];
    topGradientLayer.locations = @[@0, @1];
    topGradientLayer.startPoint = CGPointMake(0.5, 0);
    topGradientLayer.endPoint = CGPointMake(0.5, 1);
    
    [self.topBackView.layer insertSublayer:topGradientLayer atIndex:0];
    
    self.bottomGradientLayer = [[CAGradientLayer alloc] init];
    CGRect bottomFrame = self.bottomBackView.bounds;
    bottomFrame.size.width = maxWidth;
    self.bottomGradientLayer.frame = bottomFrame;
    self.bottomGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor];
    self.bottomGradientLayer.locations = @[@0, @1];
    self.bottomGradientLayer.startPoint = CGPointMake(0.5, 0);
    self.bottomGradientLayer.endPoint = CGPointMake(0.5, 1);
    [self.bottomBackView.layer insertSublayer:self.bottomGradientLayer atIndex:0];
    
    [self.playbackSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.playbackSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateHighlighted];
    
    [self registerApplicationNotification];
}

- (void)showControlView {
    if(_isShowed) {
        return;
    }
    
    _isShowed = YES;
    
    [self resumeTimer];
    
    if (_isFullScreen) {
        if (self.statusBarDelegate && [self.statusBarDelegate respondsToSelector:@selector(changeStatusBarHidden:)]) {
            [self.statusBarDelegate changeStatusBarHidden:NO];
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    [_topControlView setHidden:NO];
    [_bottomControlView setHidden:NO];
    
    //alpha animation
    /*
    _topControlView.alpha = 0;
    _bottomControlView.alpha = 0;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1f animations:^{
        weakSelf.topControlView.alpha = 1;
        weakSelf.bottomControlView.alpha = 1;
    } completion:^(BOOL finished) {
        [weakSelf performSelector:@selector(hideControlView) withObject:nil afterDelay:5.0f];
    }];
    */
    [_topControlView.layer removeAllAnimations];
    [_bottomControlView.layer removeAllAnimations];
    
    CABasicAnimation *topShowAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    topShowAnim.fromValue = @(-_topControlView.bounds.size.height);
    topShowAnim.toValue = @(0);
    topShowAnim.duration = 0.1;
    topShowAnim.repeatCount = 0;
    topShowAnim.removedOnCompletion = NO;
    topShowAnim.fillMode = kCAFillModeForwards;
    topShowAnim.delegate = self;
    
    [_topControlView.layer addAnimation:topShowAnim forKey:@"show"];
    
    CABasicAnimation *bottomShowAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    bottomShowAnim.fromValue = @(_bottomControlView.bounds.size.height);
    bottomShowAnim.toValue = @(0);
    bottomShowAnim.duration = 0.1;
    bottomShowAnim.repeatCount = 0;
    bottomShowAnim.fillMode = kCAFillModeForwards;
    bottomShowAnim.removedOnCompletion = NO;
    
    [_bottomControlView.layer addAnimation:bottomShowAnim forKey:@"show"];
    
}

- (void)hideControlView {
    if(!_isShowed) {
        return;
    }
    
    if (_isFullScreen) {
        if (_isFullScreen) {
            if (self.statusBarDelegate && [self.statusBarDelegate respondsToSelector:@selector(changeStatusBarHidden:)]) {
                [self.statusBarDelegate changeStatusBarHidden:YES];
            }
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    // alpha animation
    /*
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1f animations:^{
        weakSelf.topControlView.alpha = 0;
        weakSelf.bottomControlView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.topControlView setHidden:YES];
        [weakSelf.bottomControlView setHidden:YES];
        
        [weakSelf pauseTimer];
        
        self->_isShowed = NO;
    }];
     */
    [_topControlView.layer removeAllAnimations];
    [_bottomControlView.layer removeAllAnimations];
    
    CABasicAnimation *topShowAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    topShowAnim.fromValue = @(0);
    topShowAnim.toValue = @(-_topControlView.bounds.size.height);
    topShowAnim.duration = 0.1;
    topShowAnim.repeatCount = 0;
    topShowAnim.removedOnCompletion = NO;
    topShowAnim.fillMode = kCAFillModeForwards;
    topShowAnim.delegate = self;
    
    [_topControlView.layer addAnimation:topShowAnim forKey:@"hide"];
    
    CABasicAnimation *bottomShowAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    bottomShowAnim.fromValue = @(0);
    bottomShowAnim.toValue = @(_bottomControlView.bounds.size.height);
    bottomShowAnim.duration = 0.1;
    bottomShowAnim.repeatCount = 0;
    bottomShowAnim.fillMode = kCAFillModeForwards;
    bottomShowAnim.removedOnCompletion = NO;
    
    [_bottomControlView.layer addAnimation:bottomShowAnim forKey:@"hide"];
}


#pragma mark animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([_topControlView.layer animationForKey:@"show"] == anim) {
        if (flag) {
            [self performSelector:@selector(hideControlView) withObject:nil afterDelay:5.0f];
            
            [_topControlView.layer removeAllAnimations];
            [_bottomControlView.layer removeAllAnimations];
        }
    }
    if ([_topControlView.layer animationForKey:@"hide"] == anim) {
        if (flag) {
            [_topControlView setHidden:YES];
            [_bottomControlView setHidden:YES];
            
            [self pauseTimer];
            _isShowed = NO;
            
            [_topControlView.layer removeAllAnimations];
            [_bottomControlView.layer removeAllAnimations];
        }
    }
}


- (void)stop {
    [self deregisterPlayerNotification];
    [self deregisterApplicationNotification];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)refreshMediaControl {
    NSTimeInterval duration = [_player currentItemDuration];
    NSTimeInterval position = [_player currentPlaybackTime];
    
    if (isnan(duration) || isnan(position)) {
        return;
    }
    
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
        [_playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    }
    else {
        if(_isComplete) {
            _isComplete = NO;
        }
        [_player play];
        [_playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
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

- (IBAction)nextButtonTapped:(id)sender {
    if (nextButtonActionBlock) {
        nextButtonActionBlock();
    }
}
- (IBAction)clickEyeButton:(id)sender {
    if ([self.statusBarDelegate respondsToSelector:@selector(switchVideoNetModeStateOff:)]) {
        [self.statusBarDelegate switchVideoNetModeStateOff:true];
    }
}

//- (IBAction)moreButtonDidClicked:(id)sender {
//    
//    [self initMoreButtonView];
//    
//}
- (IBAction)switchButtonDidClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([self.statusBarDelegate respondsToSelector:@selector(switchVideoNetModeStateOff:)]) {
        [self.statusBarDelegate switchVideoNetModeStateOff:!sender.selected];
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

- (void)checkCurrentItemDurationAvailable {
    NSTimeInterval duration = [_player currentItemDuration];
    if(isnan(duration)) {
        [_playbackSlider setMaximumValue:0];
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf checkCurrentItemDurationAvailable];
        });
        return;
    }
    
     [_playbackSlider setMaximumValue:duration];
    
    _playbackSlider.enabled = YES;
    
    if(duration > 3600) {
        _isLongTime = YES;
        [_timeLabel setFont:[UIFont systemFontOfSize:9]];
    }
    else {
        _isLongTime = NO;
        [_timeLabel setFont:[UIFont systemFontOfSize:10]];
    }
    
    [self refreshMediaControl];
    
    if(!_refreshTimer) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshMediaControl) userInfo:nil repeats:YES];
        if(!_isShowed) {
            [self pauseTimer];
        }
    }
}

#pragma mark -- Notification
#pragma mark player notification
- (void)playerIsPreparedToPlay:(NSNotification *)notification {
    
    [self checkCurrentItemDurationAvailable];
    
    [self playButtonTapped:nil];
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification {
    [_playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
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
