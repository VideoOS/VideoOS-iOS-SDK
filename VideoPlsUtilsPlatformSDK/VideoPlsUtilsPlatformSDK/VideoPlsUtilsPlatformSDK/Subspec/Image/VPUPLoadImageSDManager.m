//
//  VPUPSDWebImageManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLoadImageSDManager.h"
#import "VPUPLoadImageBaseConfig.h"
#import "VPUPLoadImageButtonConfig.h"
#import "VPUPLoadImageFrameListConfig.h"

#import "VPUPImageFrameList.h"
#import "VPUPImageFrame.h"
#import "VPUPPrefetchImageManager.h"
#import "VPUPLoadImageWebPURL.h"

#ifdef VPUPSDWebImage

#import "VPUPSDWebImageManager.h"
#import "UIView+VPUPWebCacheOperation.h"
#import "NSData+VPUPImageContentType.h"
#import "VPUPSDWebImagePrefetcher.h"

#define NSSDWebImageManager VPUPSDWebImageManager
#define NSSDWebImagePrefetcher VPUPSDWebImagePrefetcher
#define NSSDImageCache VPUPSDImageCache
#define NSSDWebImageDownloader VPUPSDWebImageDownloader

#else

#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIView+WebCacheOperation.h>
#import <SDWebImage/NSData+ImageContentType.h>
#import <SDWebImage/SDWebImagePrefetcher.h>

#define NSSDWebImageManager SDWebImageManager
#define NSSDWebImagePrefetcher SDWebImagePrefetcher
#define NSSDImageCache SDImageCache
#define NSSDWebImageDownloader SDWebImageDownloader

#endif

#import <objc/runtime.h>

#import "VPUPFLAnimatedImage.h"
#import "VPUPFLAnimatedImageView.h"
#import "VPUPFLAnimatedFrameImage.h"
#import "VPUPPrefetchImageManager.h"
#import "VPUPServiceManager.h"

//static char vpup_imageURLKey;

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

static NSSDWebImageManager* webImageManager() {
    static NSSDWebImageManager *webImageManager = nil;
    
    if(!webImageManager) {
        NSSDImageCache *imageCache = [[NSSDImageCache alloc] initWithNamespace:@"videopls"];
        NSSDWebImageDownloader *imageDownloader = [[NSSDWebImageDownloader alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        webImageManager = [[NSSDWebImageManager alloc] initWithCache:imageCache downloader:imageDownloader];
    }
    
    return webImageManager;
}

static NSSDWebImagePrefetcher* prefetchImageManager() {
    static NSSDWebImagePrefetcher *prefetchImageManager = nil;
    
    if(!prefetchImageManager) {
        prefetchImageManager = [[NSSDWebImagePrefetcher alloc] initWithImageManager:webImageManager()];
#ifdef VPUPSDWebImage
        prefetchImageManager.options = VPUPSDWebImageRetryFailed | VPUPSDWebImageLowPriority | VPUPSDWebImageContinueInBackground;
#else
        prefetchImageManager.options = SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageContinueInBackground;
#endif
    }
    
    return prefetchImageManager;
}

@implementation VPUPLoadImageSDManager

+ (void)load {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPLoadImageManager) implClass:[VPUPLoadImageSDManager class]];
}

- (instancetype)init {
    self = [super init];
    if(self) {

    }
    return self;
}


#ifdef VPUPSDWebImage

- (void)loadImageWithConfig:(VPUPLoadImageBaseConfig *)config {
    UIView *view = config.view;
    NSURL *url = [config getWebPURL];
    __block VPUPLoadImageBaseConfig *blockConfig = config;
    
    if([config isKindOfClass:[VPUPLoadImageFrameListConfig class]]) {
        url = [[[((VPUPLoadImageFrameListConfig *)config).frameList frames] firstObject] imageURL];
    }
    
    NSAssert([url isKindOfClass:[NSURL class]], @"url is not a class with NSURL");
    
    if(!url) {
        return;
    }
    
    //imageView 前置
    __block UIViewContentMode currentContentMode;
    __block UIColor *originalBackgroundColor;
    //    dispatch_main_async_safe(^{
    [self imagePretreatmentWithView:view config:config currentContentMode:&currentContentMode originalBackgroundColor:&originalBackgroundColor];
    //    });
    
    VPUPSDWebImageOptions options = (VPUPSDWebImageOptions)config.options;
    NSString *validOperationKey = nil;
    
    if([config isKindOfClass:[VPUPLoadImageButtonConfig class]]) {
        VPUPLoadImageButtonConfig *buttonConfig = (VPUPLoadImageButtonConfig *)config;
        
        if(buttonConfig.isBackgroundImage) {
            validOperationKey = [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(buttonConfig.state)];
        }
        else {
            validOperationKey = [NSString stringWithFormat:@"UIButtonImageOperation%@", @(buttonConfig.state)];
        }
    }
    validOperationKey = validOperationKey ?: NSStringFromClass([view class]);
    
    [view vpupsd_cancelImageLoadOperationWithKey:validOperationKey];
    
    //    objc_setAssociatedObject(view, &vpup_imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak __typeof(self)wself = self;
    __weak __typeof(view)wview = view;
    
    if (!(options & VPUPSDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            //设置placeholder
            [wself setImage:blockConfig.placeholder imageData:nil view:wview config:blockConfig];
            if([wview isKindOfClass:[UIImageView class]]) {
                if(blockConfig.placeholderBackgroundColor) {
                    wview.layer.backgroundColor = blockConfig.placeholderBackgroundColor.CGColor;
                }
            }
        });
    }
    
    id <VPUPSDWebImageOperation> operation =
    [webImageManager() loadImageWithURL:url
                                options:options
                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                   if(blockConfig.progressBlock) {
                                       blockConfig.progressBlock(receivedSize, expectedSize);
                                   }
                               }
                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, VPUPSDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                  __strong __typeof (wself) sself = wself;
                                  __strong __typeof (wview) sview = wview;
                                  
                                  if(!sview) {
                                      return ;
                                  }
                                  dispatch_main_async_safe(^{
                                      if(!sview) {
                                          return ;
                                      }
                                      if (image && (options & VPUPSDWebImageAvoidAutoSetImage)) {
                                          if(!error) {
                                              [sself imageLoadCompleteWithView:sview currentContentMode:currentContentMode originalBackgroundColor:originalBackgroundColor];
                                          }
                                          if(blockConfig.completedBlock) {
                                              blockConfig.completedBlock(image, error, (VPUPImageCacheType)cacheType, url);
                                          }
                                          return;
                                      }
                                      else if(image) {
                                          [sself setImage:image imageData:data view:sview config:blockConfig];
                                          [sview setNeedsLayout];
                                      }
                                      else {
                                          if ((options & VPUPSDWebImageDelayPlaceholder)) {
                                              [sself setImage:blockConfig.placeholder imageData:nil view:sview config:blockConfig];
                                              [sview setNeedsLayout];
                                          }
                                      }
                                      if(finished) {
                                          if(!error) {
                                              [sself imageLoadCompleteWithView:sview currentContentMode:currentContentMode originalBackgroundColor:originalBackgroundColor];
                                          }
                                          if(blockConfig.completedBlock) {
                                              blockConfig.completedBlock(image, error, (VPUPImageCacheType)cacheType, url);
                                          }
                                      }
                                      
                                  });
                              }];
    [view vpupsd_setImageLoadOperation:operation forKey:validOperationKey];
}

#else

- (void)loadImageWithConfig:(VPUPLoadImageBaseConfig *)config {
    UIView *view = config.view;
    NSURL *url = [config getWebPURL];
    __block VPUPLoadImageBaseConfig *blockConfig = config;
    
    if([config isKindOfClass:[VPUPLoadImageFrameListConfig class]]) {
        url = [[[((VPUPLoadImageFrameListConfig *)config).frameList frames] firstObject] imageURL];
    }
    
    NSAssert([url isKindOfClass:[NSURL class]], @"url is not a class with NSURL");
    
    if(!url) {
        return;
    }
    
    //imageView 前置
    __block UIViewContentMode currentContentMode;
    __block UIColor *originalBackgroundColor;
//    dispatch_main_async_safe(^{
        [self imagePretreatmentWithView:view config:config currentContentMode:&currentContentMode originalBackgroundColor:&originalBackgroundColor];
//    });
    
    SDWebImageOptions options = (SDWebImageOptions)config.options;
    NSString *validOperationKey = nil;
    
    if([config isKindOfClass:[VPUPLoadImageButtonConfig class]]) {
        VPUPLoadImageButtonConfig *buttonConfig = (VPUPLoadImageButtonConfig *)config;
        
        if(buttonConfig.isBackgroundImage) {
            validOperationKey = [NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(buttonConfig.state)];
        }
        else {
            validOperationKey = [NSString stringWithFormat:@"UIButtonImageOperation%@", @(buttonConfig.state)];
        }
    }
    validOperationKey = validOperationKey ?: NSStringFromClass([view class]);
    
    [view sd_cancelImageLoadOperationWithKey:validOperationKey];
    
//    objc_setAssociatedObject(view, &vpup_imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    __weak __typeof(self)wself = self;
    __weak __typeof(view)wview = view;
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            //设置placeholder
            [wself setImage:blockConfig.placeholder imageData:nil view:wview config:blockConfig];
            if([wview isKindOfClass:[UIImageView class]]) {
                if(blockConfig.placeholderBackgroundColor) {
                    wview.layer.backgroundColor = blockConfig.placeholderBackgroundColor.CGColor;
                }
            }
        });
    }
    
    id <SDWebImageOperation> operation =
    [webImageManager() loadImageWithURL:url
                                options:options
                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                   if(blockConfig.progressBlock) {
                                       blockConfig.progressBlock(receivedSize, expectedSize);
                                   }
                               }
                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                  __strong __typeof (wself) sself = wself;
                                  __strong __typeof (wview) sview = wview;
                                  
                                  if(!sview) {
                                      return ;
                                  }
                                  dispatch_main_async_safe(^{
                                      if(!sview) {
                                          return ;
                                      }
                                      if (image && (options & SDWebImageAvoidAutoSetImage)) {
                                          if(!error) {
                                              [sself imageLoadCompleteWithView:sview currentContentMode:currentContentMode originalBackgroundColor:originalBackgroundColor];
                                          }
                                          if(blockConfig.completedBlock) {
                                              blockConfig.completedBlock(image, error, (VPUPImageCacheType)cacheType, url);
                                          }
                                          return;
                                      }
                                      else if(image) {
                                          [sself setImage:image imageData:data view:sview config:blockConfig];
                                          [sview setNeedsLayout];
                                      }
                                      else {
                                          if ((options & SDWebImageDelayPlaceholder)) {
                                              [sself setImage:blockConfig.placeholder imageData:nil view:sview config:blockConfig];
                                              [sview setNeedsLayout];
                                          }
                                      }
                                      if(finished) {
                                          if(!error) {
                                              [sself imageLoadCompleteWithView:sview currentContentMode:currentContentMode originalBackgroundColor:originalBackgroundColor];
                                          }
                                          if(blockConfig.completedBlock) {
                                              blockConfig.completedBlock(image, error, (VPUPImageCacheType)cacheType, url);
                                          }
                                      }
                                      
                                  });
                              }];
    [view sd_setImageLoadOperation:operation forKey:validOperationKey];
}

#endif

- (void)clearMemory {
    [[webImageManager() imageCache] clearMemory];
}

#ifdef VPUPSDWebImage

- (void)setImage:(UIImage *)image imageData:(NSData *)data view:(UIView *)view config:(VPUPLoadImageBaseConfig *)config {
    if(data) {
        if([view isKindOfClass:[VPUPFLAnimatedImageView class]]) {
            VPUPFLAnimatedImageView *imageView = (VPUPFLAnimatedImageView *)view;
            if([config isKindOfClass:[VPUPLoadImageFrameListConfig class]]) {
                VPUPLoadImageFrameListConfig *frameConfig = (VPUPLoadImageFrameListConfig *)config;
                VPUPFLAnimatedFrameImage *animatedImage = [VPUPFLAnimatedFrameImage animatedImageWithFrameList:frameConfig.frameList firstImage:image imageManager:webImageManager()];
                imageView.animatedImage = animatedImage;
                imageView.image = nil;
                __weak typeof(imageView) weakImageView = imageView;
                __block void(^loopCompleteBlock)(NSUInteger loopCountRemaining) = imageView.loopCompletionBlock;
                imageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if(loopCountRemaining == 0) {
                        [((VPUPFLAnimatedFrameImage *)weakImageView.animatedImage) cleanCache];
                        [webImageManager().imageCache clearMemory];
                    }
                    if(loopCompleteBlock) {
                        loopCompleteBlock(loopCountRemaining);
                    }
                };
            }
            else {
                VPUPSDImageFormat imageFormat = [NSData vpupsd_imageFormatForImageData:data];
                if (imageFormat == VPUPSDImageFormatGIF) {
                    imageView.animatedImage = [VPUPFLAnimatedImage animatedImageWithGIFData:data];
                    imageView.image = nil;
                } else {
                    imageView.image = image;
                    imageView.animatedImage = nil;
                }
            }
            return;
        }
    }
    
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        imageView.image = image;
    }
    
    UIControlState state = [config isKindOfClass:[VPUPLoadImageButtonConfig class]] ? ((VPUPLoadImageButtonConfig *)config).state : UIControlStateNormal;
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        if(((VPUPLoadImageButtonConfig *)config).isBackgroundImage) {
            [button setBackgroundImage:image forState:state];
        }
        else {
            [button setImage:image forState:state];
        }
    }
}

#else

- (void)setImage:(UIImage *)image imageData:(NSData *)data view:(UIView *)view config:(VPUPLoadImageBaseConfig *)config {
    if(data) {
        if([view isKindOfClass:[VPUPFLAnimatedImageView class]]) {
            VPUPFLAnimatedImageView *imageView = (VPUPFLAnimatedImageView *)view;
            if([config isKindOfClass:[VPUPLoadImageFrameListConfig class]]) {
                VPUPLoadImageFrameListConfig *frameConfig = (VPUPLoadImageFrameListConfig *)config;
                VPUPFLAnimatedFrameImage *animatedImage = [VPUPFLAnimatedFrameImage animatedImageWithFrameList:frameConfig.frameList firstImage:image imageManager:webImageManager()];
                imageView.animatedImage = animatedImage;
                imageView.image = nil;
                __weak typeof(imageView) weakImageView = imageView;
                __block void(^loopCompleteBlock)(NSUInteger loopCountRemaining) = imageView.loopCompletionBlock;
                imageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
                    if(loopCountRemaining == 0) {
                        [((VPUPFLAnimatedFrameImage *)weakImageView.animatedImage) cleanCache];
                        [webImageManager().imageCache clearMemory];
                    }
                    if(loopCompleteBlock) {
                        loopCompleteBlock(loopCountRemaining);
                    }
                };
            }
            else {
                SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:data];
                if (imageFormat == SDImageFormatGIF) {
                    imageView.animatedImage = [VPUPFLAnimatedImage animatedImageWithGIFData:data];
                    imageView.image = nil;
                } else {
                    imageView.image = image;
                    imageView.animatedImage = nil;
                }
            }
            return;
        }
    }
    
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        imageView.image = image;
    }
    
    UIControlState state = [config isKindOfClass:[VPUPLoadImageButtonConfig class]] ? ((VPUPLoadImageButtonConfig *)config).state : UIControlStateNormal;
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        if(((VPUPLoadImageButtonConfig *)config).isBackgroundImage) {
            [button setBackgroundImage:image forState:state];
        }
        else {
            [button setImage:image forState:state];
        }
    }
}

#endif

- (void)imagePretreatmentWithView:(UIView *)view
                           config:(VPUPLoadImageBaseConfig *)config
               currentContentMode:(UIViewContentMode *)currentContentMode
          originalBackgroundColor:(UIColor **)originalBackgroundColor {
    if([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        *currentContentMode = imageView.contentMode;
        
        if(config.placeholder) {
            UIViewContentMode changeContentMode = config.placeholderContentMode;
            //判断placeHolder图片会不会超出imagview,并修改contentMode(暂时只针对center)
            if(changeContentMode == UIViewContentModeCenter) {
                if(config.placeholder.size.width > imageView.bounds.size.width || config.placeholder.size.height > imageView.bounds.size.height) {
                    changeContentMode = UIViewContentModeScaleAspectFit;
                }
            }
            imageView.contentMode = changeContentMode;
        }
        
        *originalBackgroundColor = imageView.backgroundColor;
    }
}

- (void)imageLoadCompleteWithView:(UIView *)view
               currentContentMode:(UIViewContentMode)currentContentMode
          originalBackgroundColor:(UIColor *)originalBackgroundColor {
    if([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        imageView.layer.backgroundColor = originalBackgroundColor.CGColor;
        imageView.contentMode = currentContentMode;
    }
}

- (NSSDWebImageManager *)webImageManager {
    return webImageManager();
}

- (void)loadImageWithButtonConfig:(VPUPLoadImageButtonConfig *)config {
    [self loadImageWithConfig:config];
}

- (void)loadImageWithFrameListConfig:(VPUPLoadImageFrameListConfig *)config {
    [self loadImageWithConfig:config];
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls {
    [self prefetchURLs:urls completionBlock:nil];
}


- (void)prefetchURLs:(NSArray<NSString *> *)urls
     completionBlock:(void(^)(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls))completionBlock {
    
    NSMutableArray *urlArray = [NSMutableArray array];
    [urls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL URLWithString:obj];
        //图片需要添加webp
        url = [VPUPLoadImageWebPURL webPURLFromURL:url];
        
        NSAssert(url, @"url String maybe have some trouble");
        if(url) {
            [urlArray addObject:url];
        }
    }];
    
    [prefetchImageManager() prefetchURLs:urlArray progress:nil completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
        if(completionBlock) {
            completionBlock(noOfFinishedUrls, noOfSkippedUrls);
        }
    }];
}

- (void)cancelPrefetching {
    [prefetchImageManager() cancelPrefetching];
}

@end
