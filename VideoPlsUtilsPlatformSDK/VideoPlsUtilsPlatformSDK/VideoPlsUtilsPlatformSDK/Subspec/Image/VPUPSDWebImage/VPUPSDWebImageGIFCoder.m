/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageGIFCoder.h"
#import "NSImage+VPUPWebCache.h"
#import <ImageIO/ImageIO.h>
#import "NSData+VPUPImageContentType.h"
#import "UIImage+VPUPMultiFormat.h"
#import "VPUPSDWebImageCoderHelper.h"

@implementation VPUPSDWebImageGIFCoder

+ (instancetype)sharedCoder {
    static VPUPSDWebImageGIFCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[VPUPSDWebImageGIFCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(nullable NSData *)data {
    return ([NSData vpupsd_imageFormatForImageData:data] == VPUPSDImageFormatGIF);
}

- (UIImage *)decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
#if VPUPSD_MAC
    return [[UIImage alloc] initWithData:data];
#else
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray<VPUPSDWebImageFrame *> *frames = [NSMutableArray array];
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                continue;
            }
            
            float duration = [self vpupsd_frameDurationAtIndex:i source:source];
#if VPUPSD_WATCH
            CGFloat scale = 1;
            scale = [WKInterfaceDevice currentDevice].screenScale;
#elif VPUPSD_UIKIT
            CGFloat scale = 1;
            scale = [UIScreen mainScreen].scale;
#endif
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
            CGImageRelease(imageRef);
            
            VPUPSDWebImageFrame *frame = [VPUPSDWebImageFrame frameWithImage:image duration:duration];
            [frames addObject:frame];
        }
        
        NSUInteger loopCount = 0;
        NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(source, nil);
        NSDictionary *gifProperties = [imageProperties valueForKey:(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary];
        if (gifProperties) {
            NSNumber *gifLoopCount = [gifProperties valueForKey:(__bridge_transfer NSString *)kCGImagePropertyGIFLoopCount];
            if (gifLoopCount) {
                loopCount = gifLoopCount.unsignedIntegerValue;
            }
        }
        
        animatedImage = [VPUPSDWebImageCoderHelper animatedImageWithFrames:frames];
        animatedImage.vpupsd_imageLoopCount = loopCount;
    }
    
    CFRelease(source);
    
    return animatedImage;
#endif
}

- (float)vpupsd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
    // GIF do not decompress
    return image;
}

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(VPUPSDImageFormat)format {
    return (format == VPUPSDImageFormatGIF);
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(VPUPSDImageFormat)format {
    if (!image) {
        return nil;
    }
    
    if (format != VPUPSDImageFormatGIF) {
        return nil;
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData vpupsd_UTTypeFromSDImageFormat:VPUPSDImageFormatGIF];
    NSArray<VPUPSDWebImageFrame *> *frames = [VPUPSDWebImageCoderHelper framesFromAnimatedImage:image];
    
    // Create an image destination. GIF does not support EXIF image orientation
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, frames.count, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    if (frames.count == 0) {
        // for static single GIF images
        CGImageDestinationAddImage(imageDestination, image.CGImage, nil);
    } else {
        // for animated GIF images
        NSUInteger loopCount = image.vpupsd_imageLoopCount;
        NSDictionary *gifProperties = @{(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary: @{(__bridge_transfer NSString *)kCGImagePropertyGIFLoopCount : @(loopCount)}};
        CGImageDestinationSetProperties(imageDestination, (__bridge CFDictionaryRef)gifProperties);
        
        for (size_t i = 0; i < frames.count; i++) {
            VPUPSDWebImageFrame *frame = frames[i];
            float frameDuration = frame.duration;
            CGImageRef frameImageRef = frame.image.CGImage;
            NSDictionary *frameProperties = @{(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary : @{(__bridge_transfer NSString *)kCGImagePropertyGIFUnclampedDelayTime : @(frameDuration)}};
            CGImageDestinationAddImage(imageDestination, frameImageRef, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

@end

#endif
