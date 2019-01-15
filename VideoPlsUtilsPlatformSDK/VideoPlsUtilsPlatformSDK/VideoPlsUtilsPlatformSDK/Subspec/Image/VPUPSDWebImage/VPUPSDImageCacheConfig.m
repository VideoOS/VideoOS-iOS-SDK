/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDImageCacheConfig.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@implementation VPUPSDImageCacheConfig

- (instancetype)init {
    if (self = [super init]) {
        _shouldDecompressImages = YES;
        _shouldDisableiCloud = YES;
        _shouldCacheImagesInMemory = YES;
        _diskCacheReadingOptions = 0;
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        _maxCacheSize = 0;
    }
    return self;
}

@end

#endif
