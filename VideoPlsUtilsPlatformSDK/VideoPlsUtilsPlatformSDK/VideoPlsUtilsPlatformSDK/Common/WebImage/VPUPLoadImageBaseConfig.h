//
//  VPUPLoadImageBaseConfig.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  该枚举值等同于 VPUPSDWebImageOptions
 */
typedef NS_OPTIONS(NSUInteger, VPUPWebImageOptions) {
    VPUPWebImageRetryFailed = 1 << 0,
    VPUPWebImageLowPriority = 1 << 1,
    VPUPWebImageCacheMemoryOnly = 1 << 2,
    VPUPWebImageProgressiveDownload = 1 << 3,
    VPUPWebImageRefreshCached = 1 << 4,
    VPUPWebImageContinueInBackground = 1 << 5,
    VPUPWebImageHandleCookies = 1 << 6,
    VPUPWebImageAllowInvalidSSLCertificates = 1 << 7,
    VPUPWebImageHighPriority = 1 << 8,
    VPUPWebImageDelayPlaceholder = 1 << 9,
    VPUPWebImageTransformAnimatedImage = 1 << 10,
    VPUPWebImageAvoidAutoSetImage = 1 << 11
};

typedef NS_ENUM(NSUInteger, VPUPImageCacheType) {
    /**
     *  这个 image 没有缓存，从网络中加载的
     */
    VPUPImageCacheTypeNone,
    /**
     *  这个 image 是从硬盘缓存中取得
     */
    VPUPImageCacheTypeDisk,
    /**
     *  这个 image 是从内存缓存中取得
     */
    VPUPImageCacheTypeMemory
};

typedef void(^VPUPLoadImageCompletionBlock)(UIImage *image, NSError *error, VPUPImageCacheType cacheType, NSURL *imageURL);
typedef void(^VPUPLoadImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

@interface VPUPLoadImageBaseConfig : NSObject

/**
 *  加载Image使用的View(UIImageView或UIButton或VPUPFLAnimatedImageView)
 */
@property (nonatomic, weak) UIView *view;

/**
 *  加载图片所用的url
 */
@property (nonatomic, copy) NSURL *url;

/**
 *  占位图
 */
@property (nonatomic, strong) UIImage *placeholder;

/**
 *  占位图片的背景颜色，仅在有占位图片时有作用
 */
@property (nonatomic, strong) UIColor *placeholderBackgroundColor;

/**
 *  占位图在imageview中的模式默认为UIViewContentModeCenter
 */
@property (nonatomic, assign) UIViewContentMode placeholderContentMode;

/**
 *  下载图片选项
 */
@property (nonatomic, assign) VPUPWebImageOptions options;

/**
 *  图片下载进度回调
 */
@property (nonatomic, copy) VPUPLoadImageDownloaderProgressBlock progressBlock;

/**
 *  图片下载完成回调
 */
@property (nonatomic, copy) VPUPLoadImageCompletionBlock completedBlock;


- (instancetype)initWithView:(UIView *)view url:(NSURL *)url completionHandle:(VPUPLoadImageCompletionBlock)completionHandler;

- (NSURL *)getWebPURL;

@end
