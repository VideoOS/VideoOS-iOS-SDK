/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageFrame.h"

@interface VPUPSDWebImageFrame ()

@property (nonatomic, strong, readwrite, nonnull) UIImage *image;
@property (nonatomic, readwrite, assign) NSTimeInterval duration;

@end

@implementation VPUPSDWebImageFrame

+ (instancetype)frameWithImage:(UIImage *)image duration:(NSTimeInterval)duration {
    VPUPSDWebImageFrame *frame = [[VPUPSDWebImageFrame alloc] init];
    frame.image = image;
    frame.duration = duration;
    
    return frame;
}

@end

#endif
