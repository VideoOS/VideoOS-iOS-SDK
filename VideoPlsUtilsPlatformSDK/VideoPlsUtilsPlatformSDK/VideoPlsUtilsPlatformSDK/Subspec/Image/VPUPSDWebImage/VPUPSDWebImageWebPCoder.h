/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#ifdef VPUPSD_WEBP

#import <Foundation/Foundation.h>
#import "VPUPSDWebImageCoder.h"

/**
 Built in coder that supports WebP and animated WebP
 */
@interface VPUPSDWebImageWebPCoder : NSObject <VPUPSDWebImageProgressiveCoder>

+ (nonnull instancetype)sharedCoder;

@end

#endif

#endif
