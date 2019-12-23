//
//  VPMPContainerLoadingView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPContainerLoadingView.h"
#import "VPUPHexColors.h"
#import "VPUPViewScaleUtil.h"

@interface VPMPContainerLoadingView()

@property (nonatomic) UIView *outerCircleView;
@property (nonatomic) UIView *innerCircleView;
@property (nonatomic) UILabel *loadingLabel;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation VPMPContainerLoadingView

- (void)initView {
    [super initView];
    
    CGFloat cirleWidth = 25 * VPUPViewScale;
    
    _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20 * VPUPViewScale)];
    _loadingLabel.text = @"正在拼命加载中...";
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.textColor = [VPUPHXColor vpup_colorWithHexARGBString:@"cccccc"];
    _loadingLabel.font = [UIFont boldSystemFontOfSize:12 * VPUPFontScale];
    
    [self addSubview:_loadingLabel];
    
    _loadingLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 3 * VPUPViewScale);
    
    _outerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cirleWidth, cirleWidth)];
    _outerCircleView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"b6cbe5"];
    _outerCircleView.layer.cornerRadius = cirleWidth / 2;
    _outerCircleView.alpha = 0.5;
    _innerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cirleWidth, cirleWidth)];
    _innerCircleView.backgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"b6cbe5"];
    _innerCircleView.layer.cornerRadius = cirleWidth / 2;
    _innerCircleView.alpha = 0.5;
    
    [self addSubview:_outerCircleView];
    [self addSubview:_innerCircleView];
    
    _outerCircleView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 56 * VPUPViewScale);
    _innerCircleView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 56 * VPUPViewScale);

//    [self startLoading];
}

- (void)startLoading {
    if (_isLoading) {
        return;
    }
    
    _isLoading = YES;
    
    CAKeyframeAnimation *outerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    outerAnimation.values = @[@(1), @(1.4), @(1)];
    outerAnimation.keyTimes = @[@(0), @(0.5), @(1)];
    outerAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    outerAnimation.duration = 1;
    outerAnimation.repeatCount = HUGE;
    
    CAKeyframeAnimation *innerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    innerAnimation.values = @[@(1), @(0.56), @(1)];
    innerAnimation.keyTimes = @[@(0), @(0.5), @(1)];
    innerAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    innerAnimation.duration = 1;
    innerAnimation.repeatCount = HUGE;
    
    [_outerCircleView.layer addAnimation:outerAnimation forKey:@"larger"];
    [_innerCircleView.layer addAnimation:innerAnimation forKey:@"smaller"];
}


- (void)stopLoading {
    _isLoading = NO;
    [_outerCircleView.layer removeAllAnimations];
    [_innerCircleView.layer removeAllAnimations];
}


@end
