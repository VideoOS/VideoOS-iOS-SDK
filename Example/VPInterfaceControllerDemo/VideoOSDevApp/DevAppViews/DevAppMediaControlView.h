//
//  DevAppMediaControlView.h
//  VPInterfaceControllerDemo
//
//  Created by Zard1096 on 2017/7/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPAVPlayerController.h"

@protocol DevAppMediaControlStatusBarDelegate <NSObject>

- (void)changeStatusBarHidden:(BOOL)hidden;
- (void)switchVideoNetModeStateOff:(BOOL)off;
@end


@interface DevAppMediaControlView : UIView

+ (instancetype)mediaControlViewWithNib;

@property (nonatomic, weak) id<DevAppMediaControlStatusBarDelegate> statusBarDelegate;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign, readonly) BOOL isShowed;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomControlViewHeight;

@property (weak, nonatomic) IBOutlet UIView *topControlView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlView;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (strong, nonatomic) CAGradientLayer *bottomGradientLayer;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchButtonConstraintRight;
@property (weak, nonatomic) IBOutlet UIButton *eyeButton;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)playButtonTapped:(id)sender;
- (IBAction)playbackSliderTouchDown:(id)sender;
- (IBAction)playbackSliderTouchCancel:(id)sender;
- (IBAction)playbackSliderTouchUpInside:(id)sender;
- (IBAction)playbackSliderTouchUpOutside:(id)sender;
- (IBAction)nextButtonTapped:(id)sender;

- (void)setAVPlayerController:(VPAVPlayerController *)player;

- (void)setBackButtonTappedToDo:(void (^)(void))excuteBlock;
- (void)setNextButtonTappedToDo:(void (^)(void))excuteBlock;
- (void)setTitle:(NSString *)title;

- (void)showControlView;
- (void)hideControlView;

- (void)stop;

@end
