//
//  VPUPFLAnimatedFrameImage.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPFLAnimatedFrameImage.h"
#import "VPUPImageFrameList.h"
#import "VPUPImageFrame.h"

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageManager.h"
#define NSSDWebImageManager VPUPSDWebImageManager
#define NSSDWebImageRetryFailed VPUPSDWebImageRetryFailed
#define NSSDImageCacheType VPUPSDImageCacheType

#else

#import <SDWebImage/SDWebImageManager.h>
#define NSSDWebImageManager SDWebImageManager
#define NSSDWebImageRetryFailed SDWebImageRetryFailed
#define NSSDImageCacheType SDImageCacheType

#endif

#import "VPUPLoadImageManager.h"


#ifndef BYTE_SIZE
#define BYTE_SIZE 8 // byte size in bits
#endif

#define MEGABYTE (1024 * 1024)


//3.8.0
typedef void(^progressBlock)(NSInteger receivedSize,NSInteger expectedSize);
typedef void(^completed)(UIImage *image, NSError *error, NSSDImageCacheType cacheType, BOOL finished, NSURL *imageURL);

//4.2.2

typedef void(^downloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^internalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, NSSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

// This is how the fastest browsers do it as per 2012: http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
const NSTimeInterval kVPUPFLAnimatedFrameImageDelayTimeIntervalMinimum = 0.02;

// An animated image's data size (dimensions * frameCount) category; its value is the max allowed memory (in MB).
// E.g.: A 100x200px GIF with 30 frames is ~2.3MB in our pixel format and would fall into the `FLAnimatedFrameImageDataSizeCategoryAll` category.
typedef NS_ENUM(NSUInteger, VPUPFLAnimatedFrameImageDataSizeCategory) {
    VPUPFLAnimatedFrameImageDataSizeCategoryAll = 10,       // All frames permanently in memory (be nice to the CPU)
    VPUPFLAnimatedFrameImageDataSizeCategoryDefault = 75,   // A frame cache of default size in memory (usually real-time performance and keeping low memory profile)
    VPUPFLAnimatedFrameImageDataSizeCategoryOnDemand = 250, // Only keep one frame at the time in memory (easier on memory, slowest performance)
    VPUPFLAnimatedFrameImageDataSizeCategoryUnsupported     // Even for one frame too large, computer says no.
};

typedef NS_ENUM(NSUInteger, VPUPFLAnimatedFrameImageFrameCacheSize) {
    VPUPFLAnimatedFrameImageFrameCacheSizeNoLimit = 0,                // 0 means no specific limit
    VPUPFLAnimatedFrameImageFrameCacheSizeLowMemory = 1,              // The minimum frame cache size; this will produce frames on-demand.
    VPUPFLAnimatedFrameImageFrameCacheSizeGrowAfterMemoryWarning = 2, // If we can produce the frames faster than we consume, one frame ahead will already result in a stutter-free playback.
    VPUPFLAnimatedFrameImageFrameCacheSizeDefault = 5                 // Build up a comfy buffer window to cope with CPU hiccups etc.
};


#if defined(DEBUG) && DEBUG
@protocol VPUPFLAnimatedFrameImageDebugDelegate <NSObject>
@optional
- (void)debug_animatedImage:(VPUPFLAnimatedFrameImage *)animatedImage didUpdateCachedFrames:(NSIndexSet *)indexesOfFramesInCache;
- (void)debug_animatedImage:(VPUPFLAnimatedFrameImage *)animatedImage didRequestCachedFrame:(NSUInteger)index;
- (CGFloat)debug_animatedImagePredrawingSlowdownFactor:(VPUPFLAnimatedFrameImage *)animatedImage;
@end
#endif


@interface VPUPFLAnimatedFrameImage()

@property (nonatomic, strong, readonly) NSMutableArray<VPUPImageFrame *> *frames;
@property (nonatomic, weak) NSSDWebImageManager *webImageManater;

@property(copy,nonatomic) progressBlock progressblock;
@property(copy,nonatomic) completed     completedblock;
@property(copy,nonatomic) downloaderProgressBlock       downloaderProgressBlock;
@property(copy,nonatomic) internalCompletionBlock       internalCompletionBlock;
@end


@implementation VPUPFLAnimatedFrameImage
@synthesize posterImage = _posterImage;
@synthesize size = _size;
@synthesize loopCount = _loopCount;
@synthesize delayTimesForIndexes = _delayTimesForIndexes;
@synthesize frameCount = _frameCount;
@synthesize frameCacheSizeMax = _frameCacheSizeMax;


- (instancetype)init {
    VPUPFLAnimatedFrameImage *animatedImage = [self initWithAnimatedFrameList:nil
                                                                   firstImage:nil
                                                                 imageManager:nil];
    if (!animatedImage) {
        //        FLLog(FLLogLevelError, @"Use `-initWithAnimatedGIFData:` and supply the animated GIF data as an argument to initialize an object of type `FLAnimatedFrameImage`.");
    }
    return animatedImage;
}


- (instancetype)initWithAnimatedFrameList:(VPUPImageFrameList *)frameList
                               firstImage:(UIImage *)firstImage
                             imageManager:(NSSDWebImageManager *)imageManager {
    return [self initWithAnimatedFrameList:frameList
                                firstImage:firstImage
                              imageManager:imageManager
                     optimalFrameCacheSize:0
                         predrawingEnabled:YES];
}

- (instancetype)initWithAnimatedFrameList:(VPUPImageFrameList *)frameList
                               firstImage:(UIImage *)firstImage
                             imageManager:(NSSDWebImageManager *)imageManager
                    optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize
                        predrawingEnabled:(BOOL)isPredrawingEnabled {
    
    // Early return if no data supplied!
    BOOL hasData = ([[frameList frames] count] > 0);
    if (!hasData) {
        //        FLLog(FLLogLevelError, @"No animated GIF data supplied.");
        return nil;
    }
    
    //[super init] will use [FLAnimatedImage initWithData:nil], return nil
    self = [VPUPFLAnimatedFrameImage alloc];
    if (self) {
        // Do one-time initializations of `readonly` properties directly to ivar to prevent implicit actions and avoid need for private `readwrite` property overrides.
        _frames = [[frameList frames] copy];
        _predrawingEnabled = isPredrawingEnabled;
        
        // Initialize internal data structures
        _cachedFramesForIndexes = [[NSMutableDictionary alloc] init];
        _cachedFrameIndexes = [[NSMutableIndexSet alloc] init];
        _requestedFrameIndexes = [[NSMutableIndexSet alloc] init];
        
        if (!_frames || [_frames count] <= 0) {
            return nil;
        }

        _loopCount = frameList.loop;
        
        [self addLoopFrame];
        
        _webImageManater = imageManager;
        
        size_t imageCount = [_frames count];
        NSUInteger skippedFrameCount = 0;
        NSMutableDictionary *delayTimesForIndexesMutable = [NSMutableDictionary dictionaryWithCapacity:imageCount];
        
        const NSTimeInterval kDelayTimeIntervalDefault = 0.1;
        
        for (size_t i = 0; i < imageCount; i++) {
            if(firstImage) {
                if(!self.posterImage) {
                    _posterImage = firstImage;
                    _size = _posterImage.size;
                    _posterImageFrameIndex = 0;
                    [self.cachedFramesForIndexes setObject:self.posterImage forKey:@(self.posterImageFrameIndex)];
                    [self.cachedFrameIndexes addIndex:self.posterImageFrameIndex];
                }
            }
            
            NSNumber *delayTime = [NSNumber numberWithFloat:[[_frames objectAtIndex:i] duration] / 1000.0f];
            
            if ([delayTime floatValue] < ((float)kVPUPFLAnimatedFrameImageDelayTimeIntervalMinimum - FLT_EPSILON)) {
                delayTime = @(kDelayTimeIntervalDefault);
            }
            delayTimesForIndexesMutable[@(i)] = delayTime;
            
        }
        
        _delayTimesForIndexes = [delayTimesForIndexesMutable copy];
        _frameCount = imageCount;
        
        if (self.frameCount == 0) {
            //            FLLog(FLLogLevelInfo, @"Failed to create any valid frames for GIF with properties %@", imageProperties);
            return nil;
        } else if (self.frameCount == 1) {
            // Warn when we only have a single frame but return a valid GIF.
            //            FLLog(FLLogLevelInfo, @"Created valid GIF but with only a single frame. Image properties: %@", imageProperties);
        } else {
            // We have multiple frames, rock on!
        }
        
        // If no value is provided, select a default base d on the GIF.
        if (optimalFrameCacheSize == 0) {
            CGFloat animatedImageDataSize = CGImageGetBytesPerRow(self.posterImage.CGImage) * self.size.height * (self.frameCount - skippedFrameCount) / MEGABYTE;
            if (animatedImageDataSize <= VPUPFLAnimatedFrameImageDataSizeCategoryAll) {
                _frameCacheSizeOptimal = self.frameCount;
            } else if (animatedImageDataSize <= VPUPFLAnimatedFrameImageDataSizeCategoryDefault) {
                _frameCacheSizeOptimal = VPUPFLAnimatedFrameImageFrameCacheSizeDefault;
            } else {
                _frameCacheSizeOptimal = VPUPFLAnimatedFrameImageFrameCacheSizeLowMemory;
            }
        } else {
            // Use the provided value.
            _frameCacheSizeOptimal = optimalFrameCacheSize;
        }
        // In any case, cap the optimal cache size at the frame count.
        _frameCacheSizeOptimal = MIN(_frameCacheSizeOptimal, self.frameCount);
        
        // Convenience/minor performance optimization; keep an index set handy with the full range to return in `-frameIndexesToCache`.
        _allFramesIndexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.frameCount)];
        
        // See the property declarations for descriptions.
        _weakProxy = (id)[VPUPFLWeakProxy weakProxyForObject:self];
        
    }
    return self;
    
}

+ (instancetype)animatedImageWithFrameList:(VPUPImageFrameList *)frameList
                                firstImage:(UIImage *)firstImage
                              imageManager:(NSSDWebImageManager *)imageManager {
    VPUPFLAnimatedFrameImage *animatedImage = [[VPUPFLAnimatedFrameImage alloc] initWithAnimatedFrameList:frameList firstImage:firstImage imageManager:imageManager];
    return animatedImage;
}


- (void)addFrameIndexesToCache:(NSIndexSet *)frameIndexesToAddToCache
{
    // Order matters. First, iterate over the indexes starting from the requested frame index.
    // Then, if there are any indexes before the requested frame index, do those.
    NSRange firstRange = NSMakeRange(self.requestedFrameIndex, self.frameCount - self.requestedFrameIndex);
    NSRange secondRange = NSMakeRange(0, self.requestedFrameIndex);
    if (firstRange.length + secondRange.length != self.frameCount) {
        //        FLLog(FLLogLevelWarn, @"Two-part frame cache range doesn't equal full range.");
    }
    
    // Add to the requested list before we actually kick them off, so they don't get into the queue twice.
    [self.requestedFrameIndexes addIndexes:frameIndexesToAddToCache];
    
    // Lazily create dedicated isolation queue.
    if (!self.serialQueue) {
        _serialQueue = dispatch_queue_create("com.flipboard.framecachingqueue", DISPATCH_QUEUE_SERIAL);
    }
    
    // Start streaming requested frames in the background into the cache.
    // Avoid capturing self in the block as there's no reason to keep doing work if the animated image went away.
    VPUPFLAnimatedFrameImage * __weak weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        // Produce and cache next needed frame.
        void (^frameRangeBlock)(NSRange, BOOL *) = ^(NSRange range, BOOL *stop) {
            // Iterate through contiguous indexes; can be faster than `enumerateIndexesInRange:options:usingBlock:`.
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
                //加载下一张图片
                [weakSelf imageAtIndex:i completeHandler:^(UIImage *image) {
                    if (image && weakSelf) {
                        weakSelf.cachedFramesForIndexes[@(i)] = image;
                        [weakSelf.cachedFrameIndexes addIndex:i];
                        [weakSelf.requestedFrameIndexes removeIndex:i];
                    }
                    
                }];
            }
        };
        
        [frameIndexesToAddToCache enumerateRangesInRange:firstRange options:0 usingBlock:frameRangeBlock];
        [frameIndexesToAddToCache enumerateRangesInRange:secondRange options:0 usingBlock:frameRangeBlock];
    });
}

- (void)imageAtIndex:(NSUInteger)index completeHandler:(void(^)(UIImage *))completeHander {
    __weak typeof(self) weakSelf = self;
    NSURL *imageUrl = [[_frames objectAtIndex:index] imageURL];
    
    //4.2.2
    self.downloaderProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    };
    self.internalCompletionBlock = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, NSSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (weakSelf.isPredrawingEnabled) {
            if([weakSelf respondsToSelector:NSSelectorFromString(@"predrawnImageFromImage:")]) {
                SEL selector = NSSelectorFromString(@"predrawnImageFromImage:");
                IMP imp = [weakSelf methodForSelector:selector];
                id (*function)(id, SEL, UIImage *) = (void *)imp;
                id result = function(weakSelf, selector, image);
                if([result isKindOfClass:[UIImage class]]) {
                    image = (UIImage *)result;
                }
            }
        }
        if(completeHander) {
            completeHander(image);
        }
        
    };
    
    //3.8.0
    self.progressblock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        
    };
    self.completedblock = ^(UIImage *image, NSError *error, NSSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (weakSelf.isPredrawingEnabled) {
            if([weakSelf respondsToSelector:NSSelectorFromString(@"predrawnImageFromImage:")]) {
                SEL selector = NSSelectorFromString(@"predrawnImageFromImage:");
                IMP imp = [weakSelf methodForSelector:selector];
                id (*function)(id, SEL, UIImage *) = (void *)imp;
                id result = function(weakSelf, selector, image);
                if([result isKindOfClass:[UIImage class]]) {
                    image = (UIImage *)result;
                }
            }
        }
        if(completeHander) {
            completeHander(image);
        }
    };
    
    
    SEL downloadImageWithURL = @selector(downloadImageWithURL:options:progress:completed:);
    
    SEL loadImageWithURL = @selector(loadImageWithURL:options:progress:completed:);
    
    //3.8.0
    if ([[_webImageManater class] instanceMethodSignatureForSelector:downloadImageWithURL] != nil) {
        
        IMP imp = [_webImageManater methodForSelector: downloadImageWithURL];
        id (*func)(id,SEL,NSURL*,SDWebImageOptions,progressBlock,completed) = (void *)imp;
        func(_webImageManater,downloadImageWithURL,imageUrl,NSSDWebImageRetryFailed,self.progressblock,self.completedblock);
        
        //4.2.2  5.0.1
    }else if ([[_webImageManater class] instanceMethodSignatureForSelector:loadImageWithURL] != nil) {
        
        IMP imp = [_webImageManater methodForSelector: loadImageWithURL];
        void (*func)(id,SEL,NSURL*,SDWebImageOptions,downloaderProgressBlock,internalCompletionBlock) = (void *)imp;
        func(_webImageManater,loadImageWithURL,imageUrl,NSSDWebImageRetryFailed,self.downloaderProgressBlock,self.internalCompletionBlock);
    }

    
//    [_webImageManater loadImageWithURL:imageUrl
//                               options:NSSDWebImageRetryFailed
//                              progress:nil
//                             completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, NSSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
//                                 if (weakSelf.isPredrawingEnabled) {
//                                     if([weakSelf respondsToSelector:NSSelectorFromString(@"predrawnImageFromImage:")]) {
//                                         SEL selector = NSSelectorFromString(@"predrawnImageFromImage:");
//                                         IMP imp = [weakSelf methodForSelector:selector];
//                                         id (*function)(id, SEL, UIImage *) = (void *)imp;
//                                         id result = function(weakSelf, selector, image);
//                                         if([result isKindOfClass:[UIImage class]]) {
//                                             image = (UIImage *)result;
//                                         }
//                                     }
//                                 }
//                                 if(completeHander) {
//                                     completeHander(image);
//                                 }
//                             }];
}


- (NSMutableIndexSet *)frameIndexesToCache
{
    //TODO: 需要优化重复cache的帧,暂时就先全部cache
    
    NSMutableIndexSet *indexesToCache = nil;
    // Quick check to avoid building the index set if the number of frames to cache equals the total frame count.
    if (self.frameCacheSizeCurrent == self.frameCount) {
        indexesToCache = [self.allFramesIndexSet mutableCopy];
    } else {
        indexesToCache = [[NSMutableIndexSet alloc] init];
        
        // Add indexes to the set in two separate blocks- the first starting from the requested frame index, up to the limit or the end.
        // The second, if needed, the remaining number of frames beginning at index zero.
        NSUInteger firstLength = MIN(self.frameCacheSizeCurrent, self.frameCount - self.requestedFrameIndex);
        NSRange firstRange = NSMakeRange(self.requestedFrameIndex, firstLength);
        [indexesToCache addIndexesInRange:firstRange];
        NSUInteger secondLength = self.frameCacheSizeCurrent - firstLength;
        if (secondLength > 0) {
            NSRange secondRange = NSMakeRange(0, secondLength);
            [indexesToCache addIndexesInRange:secondRange];
        }
        // Double check our math, before we add the poster image index which may increase it by one.
        if ([indexesToCache count] != self.frameCacheSizeCurrent) {
            //            FLLog(FLLogLevelWarn, @"Number of frames to cache doesn't equal expected cache size.");
        }
        
        [indexesToCache addIndex:self.posterImageFrameIndex];
    }
    
    return indexesToCache;
}

- (void)addLoopFrame {
    NSMutableArray *frames = [NSMutableArray array];
    
    for(NSInteger i = 0; i < [_frames count]; i++) {
        VPUPImageFrame *frame = [_frames objectAtIndex:i];
        [frames addObject:frame];
        if(frame.jumpTo != NSUIntegerMax && frame.jumpMax != NSUIntegerMax) {
            if(frame.jumpCount < frame.jumpMax) {
                frame.jumpCount++;
                i = frame.jumpTo;
            }
            
        }
    }
    
    //reset
    for(NSInteger i = 0; i < [_frames count]; i++) {
        VPUPImageFrame *frame = [_frames objectAtIndex:i];
        frame.jumpCount = 0;
    }
    
    _frames = frames;
}

- (void)cleanCache {
    [_cachedFramesForIndexes removeAllObjects];
    [_cachedFrameIndexes removeAllIndexes];
    [_requestedFrameIndexes removeAllIndexes];
}

@end
