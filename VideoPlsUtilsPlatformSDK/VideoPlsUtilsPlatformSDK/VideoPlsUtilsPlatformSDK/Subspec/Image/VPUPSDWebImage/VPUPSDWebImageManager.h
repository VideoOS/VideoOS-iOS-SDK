/*
 * This file is part of the VPUPSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageCompat.h"
#import "VPUPSDWebImageOperation.h"
#import "VPUPSDWebImageDownloader.h"
#import "VPUPSDImageCache.h"

typedef NS_OPTIONS(NSUInteger, VPUPSDWebImageOptions) {
    /**
     * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
     * This flag disable this blacklisting.
     */
    VPUPSDWebImageRetryFailed = 1 << 0,

    /**
     * By default, image downloads are started during UI interactions, this flags disable this feature,
     * leading to delayed download on UIScrollView deceleration for instance.
     */
    VPUPSDWebImageLowPriority = 1 << 1,

    /**
     * This flag disables on-disk caching
     */
    VPUPSDWebImageCacheMemoryOnly = 1 << 2,

    /**
     * This flag enables progressive download, the image is displayed progressively during download as a browser would do.
     * By default, the image is only displayed once completely downloaded.
     */
    VPUPSDWebImageProgressiveDownload = 1 << 3,

    /**
     * Even if the image is cached, respect the HTTP response cache control, and refresh the image from remote location if needed.
     * The disk caching will be handled by NSURLCache instead of VPUPSDWebImage leading to slight performance degradation.
     * This option helps deal with images changing behind the same request URL, e.g. Facebook graph api profile pics.
     * If a cached image is refreshed, the completion block is called once with the cached image and again with the final image.
     *
     * Use this flag only if you can't make your URLs static with embedded cache busting parameter.
     */
    VPUPSDWebImageRefreshCached = 1 << 4,

    /**
     * In iOS 4+, continue the download of the image if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     */
    VPUPSDWebImageContinueInBackground = 1 << 5,

    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     */
    VPUPSDWebImageHandleCookies = 1 << 6,

    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     */
    VPUPSDWebImageAllowInvalidSSLCertificates = 1 << 7,

    /**
     * By default, images are loaded in the order in which they were queued. This flag moves them to
     * the front of the queue.
     */
    VPUPSDWebImageHighPriority = 1 << 8,
    
    /**
     * By default, placeholder images are loaded while the image is loading. This flag will delay the loading
     * of the placeholder image until after the image has finished loading.
     */
    VPUPSDWebImageDelayPlaceholder = 1 << 9,

    /**
     * We usually don't call transformDownloadedImage delegate method on animated images,
     * as most transformation code would mangle it.
     * Use this flag to transform them anyway.
     */
    VPUPSDWebImageTransformAnimatedImage = 1 << 10,
    
    /**
     * By default, image is added to the imageView after download. But in some cases, we want to
     * have the hand before setting the image (apply a filter or add it with cross-fade animation for instance)
     * Use this flag if you want to manually set the image in the completion when success
     */
    VPUPSDWebImageAvoidAutoSetImage = 1 << 11,
    
    /**
     * By default, images are decoded respecting their original size. On iOS, this flag will scale down the
     * images to a size compatible with the constrained memory of devices.
     * If `VPUPSDWebImageProgressiveDownload` flag is set the scale down is deactivated.
     */
    VPUPSDWebImageScaleDownLargeImages = 1 << 12
};

typedef void(^VPUPSDExternalCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, VPUPSDImageCacheType cacheType, NSURL * _Nullable imageURL);

typedef void(^VPUPSDInternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, VPUPSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

typedef NSString * _Nullable (^VPUPSDWebImageCacheKeyFilterBlock)(NSURL * _Nullable url);


@class VPUPSDWebImageManager;

@protocol VPUPSDWebImageManagerDelegate <NSObject>

@optional

/**
 * Controls which image should be downloaded when the image is not found in the cache.
 *
 * @param imageManager The current `VPUPSDWebImageManager`
 * @param imageURL     The url of the image to be downloaded
 *
 * @return Return NO to prevent the downloading of the image on cache misses. If not implemented, YES is implied.
 */
- (BOOL)imageManager:(nonnull VPUPSDWebImageManager *)imageManager shouldDownloadImageForURL:(nullable NSURL *)imageURL;

/**
 * Allows to transform the image immediately after it has been downloaded and just before to cache it on disk and memory.
 * NOTE: This method is called from a global queue in order to not to block the main thread.
 *
 * @param imageManager The current `VPUPSDWebImageManager`
 * @param image        The image to transform
 * @param imageURL     The url of the image to transform
 *
 * @return The transformed image object.
 */
- (nullable UIImage *)imageManager:(nonnull VPUPSDWebImageManager *)imageManager transformDownloadedImage:(nullable UIImage *)image withURL:(nullable NSURL *)imageURL;

@end

/**
 * The VPUPSDWebImageManager is the class behind the UIImageView+WebCache category and likes.
 * It ties the asynchronous downloader (VPUPSDWebImageDownloader) with the image cache store (VPUPSDImageCache).
 * You can use this class directly to benefit from web image downloading with caching in another context than
 * a UIView.
 *
 * Here is a simple example of how to use VPUPSDWebImageManager:
 *
 * @code

VPUPSDWebImageManager *manager = [VPUPSDWebImageManager sharedManager];
[manager loadImageWithURL:imageURL
                  options:0
                 progress:nil
                completed:^(UIImage *image, NSError *error, VPUPSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if (image) {
                        // do something with image
                    }
                }];

 * @endcode
 */
@interface VPUPSDWebImageManager : NSObject

@property (weak, nonatomic, nullable) id <VPUPSDWebImageManagerDelegate> delegate;

@property (strong, nonatomic, readonly, nullable) VPUPSDImageCache *imageCache;
@property (strong, nonatomic, readonly, nullable) VPUPSDWebImageDownloader *imageDownloader;

/**
 * The cache filter is a block used each time VPUPSDWebImageManager need to convert an URL into a cache key. This can
 * be used to remove dynamic part of an image URL.
 *
 * The following example sets a filter in the application delegate that will remove any query-string from the
 * URL before to use it as a cache key:
 *
 * @code

[[VPUPSDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    return [url absoluteString];
}];

 * @endcode
 */
@property (nonatomic, copy, nullable) VPUPSDWebImageCacheKeyFilterBlock cacheKeyFilter;

/**
 * Returns global VPUPSDWebImageManager instance.
 *
 * @return VPUPSDWebImageManager shared instance
 */
+ (nonnull instancetype)sharedManager;

/**
 * Allows to specify instance of cache and image downloader used with image manager.
 * @return new instance of `VPUPSDWebImageManager` with specified cache and downloader.
 */
- (nonnull instancetype)initWithCache:(nonnull VPUPSDImageCache *)cache downloader:(nonnull VPUPSDWebImageDownloader *)downloader NS_DESIGNATED_INITIALIZER;

/**
 * Downloads the image at the given URL if not present in cache or return the cached version otherwise.
 *
 * @param url            The URL to the image
 * @param options        A mask to specify options to use for this request
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed.
 *
 *   This parameter is required.
 * 
 *   This block has no return value and takes the requested UIImage as first parameter and the NSData representation as second parameter.
 *   In case of error the image parameter is nil and the third parameter may contain an NSError.
 *
 *   The forth parameter is an `VPUPSDImageCacheType` enum indicating if the image was retrieved from the local cache
 *   or from the memory cache or from the network.
 *
 *   The fith parameter is set to NO when the VPUPSDWebImageProgressiveDownload option is used and the image is
 *   downloading. This block is thus called repeatedly with a partial image. When image is fully downloaded, the
 *   block is called a last time with the full image and the last parameter set to YES.
 *
 *   The last parameter is the original image URL
 *
 * @return Returns an NSObject conforming to VPUPSDWebImageOperation. Should be an instance of VPUPSDWebImageDownloaderOperation
 */
- (nullable id <VPUPSDWebImageOperation>)loadImageWithURL:(nullable NSURL *)url
                                              options:(VPUPSDWebImageOptions)options
                                             progress:(nullable VPUPSDWebImageDownloaderProgressBlock)progressBlock
                                            completed:(nullable VPUPSDInternalCompletionBlock)completedBlock;

/**
 * Saves image to cache for given URL
 *
 * @param image The image to cache
 * @param url   The URL to the image
 *
 */

- (void)saveImageToCache:(nullable UIImage *)image forURL:(nullable NSURL *)url;

/**
 * Cancel all current operations
 */
- (void)cancelAll;

/**
 * Check one or more operations running
 */
- (BOOL)isRunning;

/**
 *  Async check if image has already been cached
 *
 *  @param url              image url
 *  @param completionBlock  the block to be executed when the check is finished
 *  
 *  @note the completion block is always executed on the main queue
 */
- (void)cachedImageExistsForURL:(nullable NSURL *)url
                     completion:(nullable VPUPSDWebImageCheckCacheCompletionBlock)completionBlock;

/**
 *  Async check if image has already been cached on disk only
 *
 *  @param url              image url
 *  @param completionBlock  the block to be executed when the check is finished
 *
 *  @note the completion block is always executed on the main queue
 */
- (void)diskImageExistsForURL:(nullable NSURL *)url
                   completion:(nullable VPUPSDWebImageCheckCacheCompletionBlock)completionBlock;


/**
 *Return the cache key for a given URL
 */
- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url;

@end

#endif
