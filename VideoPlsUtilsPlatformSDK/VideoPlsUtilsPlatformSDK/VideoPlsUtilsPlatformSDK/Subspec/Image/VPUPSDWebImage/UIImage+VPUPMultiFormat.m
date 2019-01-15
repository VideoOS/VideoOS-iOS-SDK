/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "UIImage+VPUPMultiFormat.h"

#import "objc/runtime.h"
#import "VPUPSDWebImageCodersManager.h"

@implementation UIImage (MultiFormat)

#if VPUPSD_MAC
- (NSUInteger)vpupsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    for (NSImageRep *rep in self.representations) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)rep;
            imageLoopCount = [[bitmapRep valueForProperty:NSImageLoopCount] unsignedIntegerValue];
            break;
        }
    }
    return imageLoopCount;
}

- (void)setVpupsd_imageLoopCount:(NSUInteger)vpupsd_imageLoopCount {
    for (NSImageRep *rep in self.representations) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)rep;
            [bitmapRep setProperty:NSImageLoopCount withValue:@(vpupsd_imageLoopCount)];
            break;
        }
    }
}

#else

- (NSUInteger)vpupsd_imageLoopCount {
    NSUInteger imageLoopCount = 0;
    NSNumber *value = objc_getAssociatedObject(self, @selector(vpupsd_imageLoopCount));
    if ([value isKindOfClass:[NSNumber class]]) {
        imageLoopCount = value.unsignedIntegerValue;
    }
    return imageLoopCount;
}

- (void)setVpupsd_imageLoopCount:(NSUInteger)vpupsd_imageLoopCount {
    NSNumber *value = @(vpupsd_imageLoopCount);
    objc_setAssociatedObject(self, @selector(vpupsd_imageLoopCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#endif

+ (nullable UIImage *)vpupsd_imageWithData:(nullable NSData *)data {
    return [[VPUPSDWebImageCodersManager sharedInstance] decodedImageWithData:data];
}

- (nullable NSData *)vpupsd_imageData {
    return [self vpupsd_imageDataAsFormat:VPUPSDImageFormatUndefined];
}

- (nullable NSData *)vpupsd_imageDataAsFormat:(VPUPSDImageFormat)imageFormat {
    NSData *imageData = nil;
    if (self) {
        imageData = [[VPUPSDWebImageCodersManager sharedInstance] encodedDataWithImage:self format:imageFormat];
    }
    return imageData;
}


@end

#endif
