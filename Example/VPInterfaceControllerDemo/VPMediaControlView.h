//
//  VPMediaControlView.h
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPAVPlayerController.h"

@interface VPMediaControlView : UIView

+ (instancetype)mediaControlViewWithNib;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign, readonly) BOOL isShowed;

@property (weak, nonatomic) IBOutlet UIView *topControlView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlView;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)playButtonTapped:(id)sender;
- (IBAction)playbackSliderTouchDown:(id)sender;
- (IBAction)playbackSliderTouchCancel:(id)sender;
- (IBAction)playbackSliderTouchUpInside:(id)sender;
- (IBAction)playbackSliderTouchUpOutside:(id)sender;

- (void)setAVPlayerController:(VPAVPlayerController *)player;

- (void)setBackButtonTappedToDo:(void (^)(void))excuteBlock;

- (void)showControlView;
- (void)hideControlView;

- (void)stop;

@end
