/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageCodersManager.h"
#import "VPUPSDWebImageImageIOCoder.h"
#import "VPUPSDWebImageGIFCoder.h"
#ifdef VPUPSD_WEBP
#import "VPUPSDWebImageWebPCoder.h"
#endif

@interface VPUPSDWebImageCodersManager ()

@property (nonatomic, strong, nonnull) NSMutableArray<VPUPSDWebImageCoder>* mutableCoders;
@property (VPUPSDDispatchQueueSetterSementics, nonatomic, nullable) dispatch_queue_t mutableCodersAccessQueue;

@end

@implementation VPUPSDWebImageCodersManager

+ (nonnull instancetype)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // initialize with default coders
        _mutableCoders = [@[[VPUPSDWebImageImageIOCoder sharedCoder]] mutableCopy];
#ifdef VPUPSD_WEBP
        [_mutableCoders addObject:[VPUPSDWebImageWebPCoder sharedCoder]];
#endif
        _mutableCodersAccessQueue = dispatch_queue_create("com.hackemist.VPUPSDWebImageCodersManager", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc {
    VPUPSDDispatchQueueRelease(_mutableCodersAccessQueue);
}

#pragma mark - Coder IO operations

- (void)addCoder:(nonnull id<VPUPSDWebImageCoder>)coder {
    if ([coder conformsToProtocol:@protocol(VPUPSDWebImageCoder)]) {
        dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
            [self.mutableCoders addObject:coder];
        });
    }
}

- (void)removeCoder:(nonnull id<VPUPSDWebImageCoder>)coder {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        [self.mutableCoders removeObject:coder];
    });
}

- (NSArray<VPUPSDWebImageCoder> *)coders {
    __block NSArray<VPUPSDWebImageCoder> *sortedCoders = nil;
    dispatch_sync(self.mutableCodersAccessQueue, ^{
        sortedCoders = (NSArray<VPUPSDWebImageCoder> *)[[[self.mutableCoders copy] reverseObjectEnumerator] allObjects];
    });
    return sortedCoders;
}

- (void)setCoders:(NSArray<VPUPSDWebImageCoder> *)coders {
    dispatch_barrier_sync(self.mutableCodersAccessQueue, ^{
        self.mutableCoders = [coders mutableCopy];
    });
}

#pragma mark - VPUPSDWebImageCoder
- (BOOL)canDecodeFromData:(NSData *)data {
    for (id<VPUPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(VPUPSDImageFormat)format {
    for (id<VPUPSDWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)decodedImageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    for (id<VPUPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:data]) {
            return [coder decodedImageWithData:data];
        }
    }
    return nil;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image
                                   data:(NSData *__autoreleasing  _Nullable *)data
                                options:(nullable NSDictionary<NSString*, NSObject*>*)optionsDict {
    if (!image) {
        return nil;
    }
    for (id<VPUPSDWebImageCoder> coder in self.coders) {
        if ([coder canDecodeFromData:*data]) {
            return [coder decompressedImageWithImage:image data:data options:optionsDict];
        }
    }
    return nil;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(VPUPSDImageFormat)format {
    if (!image) {
        return nil;
    }
    for (id<VPUPSDWebImageCoder> coder in self.coders) {
        if ([coder canEncodeToFormat:format]) {
            return [coder encodedDataWithImage:image format:format];
        }
    }
    return nil;
}

@end

#endif
