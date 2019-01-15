//
//  VPUPFLAnimatedFrameImage.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPFLAnimatedImage.h"
@class VPUPImageFrameList;
@class VPUPImageFrame;

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageManager.h"
#define NSSDWebImageManager VPUPSDWebImageManager

#else

#import <SDWebImage/SDWebImageManager.h>
#define NSSDWebImageManager SDWebImageManager

#endif

@interface VPUPFLAnimatedFrameImage : VPUPFLAnimatedImage

- (instancetype)initWithAnimatedFrameList:(VPUPImageFrameList *)frameList
                               firstImage:(UIImage *)firstImage
                             imageManager:(NSSDWebImageManager *)imageManager;
// Pass 0 for optimalFrameCacheSize to get the default, predrawing is enabled by default.
- (instancetype)initWithAnimatedFrameList:(VPUPImageFrameList *)frameList
                               firstImage:(UIImage *)firstImage
                             imageManager:(NSSDWebImageManager *)imageManager
                    optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize
                        predrawingEnabled:(BOOL)isPredrawingEnabled;
+ (instancetype)animatedImageWithFrameList:(VPUPImageFrameList *)frameList
                                firstImage:(UIImage *)firstImage
                              imageManager:(NSSDWebImageManager *)imageManager;




@property (nonatomic, strong, readonly) UIImage *posterImage; // Guaranteed to be loaded; usually equivalent to `-imageLazilyCachedAtIndex:0`
@property (nonatomic, assign, readonly) CGSize size; // The `.posterImage`'s `.size`

@property (nonatomic, assign, readonly) NSUInteger loopCount; // 0 means repeating the animation indefinitely

@property (nonatomic, strong, readonly) NSDictionary *delayTimesForIndexes; // Of type `NSTimeInterval` boxed in `NSNumber`s
@property (nonatomic, assign, readonly) NSUInteger frameCount; // Number of valid frames; equal to `[.delayTimes count]`

//@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent; // Current size of intelligently chosen buffer window; can range in the interval [1..frameCount]
@property (nonatomic, assign) NSUInteger frameCacheSizeMax;



@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeOptimal; // The optimal number of frames to cache based on image size & number of frames; never changes
@property (nonatomic, assign, readonly, getter=isPredrawingEnabled) BOOL predrawingEnabled; // Enables predrawing of images to improve performance.
@property (nonatomic, assign) NSUInteger frameCacheSizeMaxInternal; // Allow to cap the cache size e.g. when memory warnings occur; 0 means no specific limit (default)
@property (nonatomic, assign) NSUInteger requestedFrameIndex; // Most recently requested frame index
@property (nonatomic, assign, readonly) NSUInteger posterImageFrameIndex; // Index of non-purgable poster image; never changes
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedFramesForIndexes;
@property (nonatomic, strong, readonly) NSMutableIndexSet *cachedFrameIndexes; // Indexes of cached frames
@property (nonatomic, strong, readonly) NSMutableIndexSet *requestedFrameIndexes; // Indexes of frames that are currently produced in the background
@property (nonatomic, strong, readonly) NSIndexSet *allFramesIndexSet; // Default index set with the full range of indexes; never changes
@property (nonatomic, assign) NSUInteger memoryWarningCount;
@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;


@property (nonatomic, strong, readonly) VPUPFLAnimatedImage *weakProxy;

- (void)cleanCache;

@end
