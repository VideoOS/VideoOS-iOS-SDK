/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "VPUPSDWebImageCompat.h"

#ifdef VPUPSDWebImage

#if VPUPSD_MAC

#import <Cocoa/Cocoa.h>

@interface NSImage (VPUPWebCache)

- (CGImageRef)CGImage;
- (NSArray<NSImage *> *)images;
- (BOOL)isGIF;

@end

#endif

#endif
