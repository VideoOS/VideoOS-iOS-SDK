/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import <Foundation/Foundation.h>
#import "VPUPSDWebImageManager.h"

@class VPUPSDWebImagePrefetcher;

@protocol VPUPSDWebImagePrefetcherDelegate <NSObject>

@optional

/**
 * Called when an image was prefetched.
 *
 * @param imagePrefetcher The current image prefetcher
 * @param imageURL        The image url that was prefetched
 * @param finishedCount   The total number of images that were prefetched (successful or not)
 * @param totalCount      The total number of images that were to be prefetched
 */
- (void)imagePrefetcher:(nonnull VPUPSDWebImagePrefetcher *)imagePrefetcher didPrefetchURL:(nullable NSURL *)imageURL finishedCount:(NSUInteger)finishedCount totalCount:(NSUInteger)totalCount;

/**
 * Called when all images are prefetched.
 * @param imagePrefetcher The current image prefetcher
 * @param totalCount      The total number of images that were prefetched (whether successful or not)
 * @param skippedCount    The total number of images that were skipped
 */
- (void)imagePrefetcher:(nonnull VPUPSDWebImagePrefetcher *)imagePrefetcher didFinishWithTotalCount:(NSUInteger)totalCount skippedCount:(NSUInteger)skippedCount;

@end

typedef void(^VPUPSDWebImagePrefetcherProgressBlock)(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls);
typedef void(^VPUPSDWebImagePrefetcherCompletionBlock)(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls);

/**
 * Prefetch some URLs in the cache for future use. Images are downloaded in low priority.
 */
@interface VPUPSDWebImagePrefetcher : NSObject

/**
 *  The web image manager
 */
@property (strong, nonatomic, readonly, nonnull) VPUPSDWebImageManager *manager;

/**
 * Maximum number of URLs to prefetch at the same time. Defaults to 3.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

/**
 * VPUPSDWebImageOptions for prefetcher. Defaults to VPUPSDWebImageLowPriority.
 */
@property (nonatomic, assign) VPUPSDWebImageOptions options;

/**
 * Queue options for Prefetcher. Defaults to Main Queue.
 */
@property (VPUPSDDispatchQueueSetterSementics, nonatomic, nonnull) dispatch_queue_t prefetcherQueue;

@property (weak, nonatomic, nullable) id <VPUPSDWebImagePrefetcherDelegate> delegate;

/**
 * Return the global image prefetcher instance.
 */
+ (nonnull instancetype)sharedImagePrefetcher;

/**
 * Allows you to instantiate a prefetcher with any arbitrary image manager.
 */
- (nonnull instancetype)initWithImageManager:(nonnull VPUPSDWebImageManager *)manager NS_DESIGNATED_INITIALIZER;

/**
 * Assign list of URLs to let VPUPSDWebImagePrefetcher to queue the prefetching,
 * currently one image is downloaded at a time,
 * and skips images for failed downloads and proceed to the next image in the list.
 * Any previously-running prefetch operations are canceled.
 *
 * @param urls list of URLs to prefetch
 */
- (void)prefetchURLs:(nullable NSArray<NSURL *> *)urls;

/**
 * Assign list of URLs to let VPUPSDWebImagePrefetcher to queue the prefetching,
 * currently one image is downloaded at a time,
 * and skips images for failed downloads and proceed to the next image in the list.
 * Any previously-running prefetch operations are canceled.
 *
 * @param urls            list of URLs to prefetch
 * @param progressBlock   block to be called when progress updates; 
 *                        first parameter is the number of completed (successful or not) requests, 
 *                        second parameter is the total number of images originally requested to be prefetched
 * @param completionBlock block to be called when prefetching is completed
 *                        first param is the number of completed (successful or not) requests,
 *                        second parameter is the number of skipped requests
 */
- (void)prefetchURLs:(nullable NSArray<NSURL *> *)urls
            progress:(nullable VPUPSDWebImagePrefetcherProgressBlock)progressBlock
           completed:(nullable VPUPSDWebImagePrefetcherCompletionBlock)completionBlock;

/**
 * Remove and cancel queued list
 */
- (void)cancelPrefetching;


@end

#endif
