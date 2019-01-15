/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import <Foundation/Foundation.h>
#import "VPUPSDWebImageCompat.h"

@interface VPUPSDWebImageFrame : NSObject

// This class is used for creating animated images via `animatedImageWithFrames` in `VPUPSDWebImageCoderHelper`. Attension if you need animated images loop count, use `vpupsd_imageLoopCount` property in `UIImage+MultiFormat`

/**
 The image of current frame. You should not set an animated image.
 */
@property (nonatomic, strong, readonly, nonnull) UIImage *image;
/**
 The duration of current frame to be displayed. The number is seconds but not milliseconds. You should not set this to zero.
 */
@property (nonatomic, readonly, assign) NSTimeInterval duration;

/**
 Create a frame instance with specify image and duration

 @param image current frame's image
 @param duration current frame's duration
 @return frame instance
 */
+ (instancetype _Nonnull)frameWithImage:(UIImage * _Nonnull)image duration:(NSTimeInterval)duration;

@end

#endif
