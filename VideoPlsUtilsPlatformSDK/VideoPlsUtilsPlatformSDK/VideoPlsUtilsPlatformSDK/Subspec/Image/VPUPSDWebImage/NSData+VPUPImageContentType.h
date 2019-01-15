/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import <Foundation/Foundation.h>
#import "VPUPSDWebImageCompat.h"

typedef NS_ENUM(NSInteger, VPUPSDImageFormat) {
    VPUPSDImageFormatUndefined = -1,
    VPUPSDImageFormatJPEG = 0,
    VPUPSDImageFormatPNG,
    VPUPSDImageFormatGIF,
    VPUPSDImageFormatTIFF,
    VPUPSDImageFormatWebP,
    VPUPSDImageFormatHEIC
};

@interface NSData (VPUPImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `VPUPSDImageFormat` (enum)
 */
+ (VPUPSDImageFormat)vpupsd_imageFormatForImageData:(nullable NSData *)data;

/**
 Convert VPUPSDImageFormat to UTType

 @param format Format as VPUPSDImageFormat
 @return The UTType as CFStringRef
 */
+ (nonnull CFStringRef)vpupsd_UTTypeFromSDImageFormat:(VPUPSDImageFormat)format;

@end

#endif
