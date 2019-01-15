//
//  VPUPSVGAPlayer.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 22/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VideoPlsUtilsPlatformSDK.h"

@interface VPUPSVGAPlayer : NSObject <VPUPSVGAPlayerProtocol>

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, weak) id<VPUPSVGAPlayerDelegate> delegate;
@property (nonatomic, assign) int loops;
@property (nonatomic, assign, readonly) BOOL readyToPlay;//是否可以播放
@property (nonatomic, assign, readonly) int fps;//帧率
@property (nonatomic, assign, readonly) int frames;//总帧数

@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

- (void)setSVGAWithURL:(NSURL *)url readyToPlay:(void (^)(void))playBlock;
- (void)setSVGAWithData:(NSData *)data cacheKey:(NSString *)cacheKey readyToPlay:(void (^)(void))playBlock;

//从起始位置开始播放动画
- (void)startAnimation;
//播放range范围内的动画，reverse为YES，从后向前播放
- (void)startAnimationWithRange:(NSRange)range reverse:(BOOL)reverse;

- (void)startAnimationWithRanges:(NSArray *)ranges repeats:(NSArray *)repeats finishedRangeIndexHandle:(void(^)(NSUInteger))handle;

- (void)pauseAnimation;
- (void)stopAnimation;

//跳到指定帧，andPlay为YES，从指定帧播放
- (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay;
- (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay;

@end
