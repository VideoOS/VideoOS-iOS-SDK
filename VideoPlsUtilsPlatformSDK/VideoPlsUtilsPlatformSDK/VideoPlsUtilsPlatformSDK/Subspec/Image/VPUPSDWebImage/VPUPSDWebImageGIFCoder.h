/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import <Foundation/Foundation.h>
#import "VPUPSDWebImageCoder.h"

/**
 Built in coder using ImageIO that supports GIF encoding/decoding
 @note `VPUPSDWebImageIOCoder` supports GIF but only as static (will use the 1st frame).
 @note Use `VPUPSDWebImageGIFCoder` for fully animated GIFs - less performant than `FLAnimatedImage`
 @note If you decide to make all `UIImageView`(including `FLAnimatedImageView`) instance support GIF. You should add this coder to `VPUPSDWebImageCodersManager` and make sure that it has a higher priority than `VPUPSDWebImageIOCoder`
 @note The recommended approach for animated GIFs is using `FLAnimatedImage`. It's more performant than `UIImageView` for GIF displaying
 */
@interface VPUPSDWebImageGIFCoder : NSObject <VPUPSDWebImageCoder>

+ (nonnull instancetype)sharedCoder;

@end

#endif
