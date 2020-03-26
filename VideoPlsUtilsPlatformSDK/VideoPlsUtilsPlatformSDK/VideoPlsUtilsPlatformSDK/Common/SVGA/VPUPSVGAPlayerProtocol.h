//
//  VPUPSVGAPlayerProtocol.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 26/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#ifndef VPUPSVGAPlayerProtocol_h
#define VPUPSVGAPlayerProtocol_h

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol VPUPSVGAPlayerProtocol;

@protocol VPUPSVGAPlayerDelegate <NSObject>

@optional
- (void)svgaPlayerDidFinishedAnimation:(id<VPUPSVGAPlayerProtocol>)player;
- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame;
- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage;

@end

@protocol VPUPSVGAPlayerProtocol <NSObject>

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

#endif /* VPUPSVGAPlayerProtocol_h */
