/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageCompat.h"
#import "UIImage+VPUPMultiFormat.h"

#if !__has_feature(objc_arc)
#error VPUPSDWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

inline UIImage *VPUPSDScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    
#if VPUPSD_MAC
    return image;
#elif VPUPSD_UIKIT || VPUPSD_WATCH
    if ((image.images).count > 0) {
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];

        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:VPUPSDScaledImageForKey(key, tempImage)];
        }
        
        UIImage *animatedImage = [UIImage animatedImageWithImages:scaledImages duration:image.duration];
        if (animatedImage) {
            animatedImage.vpupsd_imageLoopCount = image.vpupsd_imageLoopCount;
        }
        return animatedImage;
    } else {
#if VPUPSD_WATCH
        if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)]) {
#elif VPUPSD_UIKIT
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
#endif
            CGFloat scale = 1;
            if (key.length >= 8) {
                NSRange range = [key rangeOfString:@"@2x."];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                
                range = [key rangeOfString:@"@3x."];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
            }

            UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            image = scaledImage;
        }
        return image;
    }
#endif
}

NSString *const VPUPSDWebImageErrorDomain = @"VPUPSDWebImageErrorDomain";
    
#endif
