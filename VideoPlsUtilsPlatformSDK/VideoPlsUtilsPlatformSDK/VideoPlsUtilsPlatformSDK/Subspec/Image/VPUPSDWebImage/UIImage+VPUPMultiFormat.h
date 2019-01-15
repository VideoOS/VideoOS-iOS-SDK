/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageCompat.h"
#import "NSData+VPUPImageContentType.h"

@interface UIImage (MultiFormat)

/**
 * UIKit:
 * For static image format, this value is always 0.
 * For animated image format, 0 means infinite looping.
 * Note that because of the limitations of categories this property can get out of sync if you create another instance with CGImage or other methods.
 * AppKit:
 * NSImage currently only support animated via GIF imageRep unlike UIImage.
 * The getter of this property will get the loop count from GIF imageRep
 * The setter of this property will set the loop count from GIF imageRep
 */
@property (nonatomic, assign) NSUInteger vpupsd_imageLoopCount;

+ (nullable UIImage *)vpupsd_imageWithData:(nullable NSData *)data;
- (nullable NSData *)vpupsd_imageData;
- (nullable NSData *)vpupsd_imageDataAsFormat:(VPUPSDImageFormat)imageFormat;

@end

#endif
