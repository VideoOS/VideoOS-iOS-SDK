/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "NSData+VPUPImageContentType.h"
#if VPUPSD_MAC
#import <CoreServices/CoreServices.h>
#else
#import <MobileCoreServices/MobileCoreServices.h>
#endif

// Currently Image/IO does not support WebP
#define kSDUTTypeWebP ((__bridge CFStringRef)@"public.webp")
// AVFileTypeHEIC is defined in AVFoundation via iOS 11, we use this without import AVFoundation
#define kSDUTTypeHEIC ((__bridge CFStringRef)@"public.heic")

@implementation NSData (VPUPImageContentType)

+ (VPUPSDImageFormat)vpupsd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return VPUPSDImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return VPUPSDImageFormatJPEG;
        case 0x89:
            return VPUPSDImageFormatPNG;
        case 0x47:
            return VPUPSDImageFormatGIF;
        case 0x49:
        case 0x4D:
            return VPUPSDImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return VPUPSDImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return VPUPSDImageFormatHEIC;
                }
            }
            break;
        }
    }
    return VPUPSDImageFormatUndefined;
}

+ (nonnull CFStringRef)vpupsd_UTTypeFromSDImageFormat:(VPUPSDImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case VPUPSDImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case VPUPSDImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case VPUPSDImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case VPUPSDImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case VPUPSDImageFormatWebP:
            UTType = kSDUTTypeWebP;
            break;
        case VPUPSDImageFormatHEIC:
            UTType = kSDUTTypeHEIC;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

@end

#endif
