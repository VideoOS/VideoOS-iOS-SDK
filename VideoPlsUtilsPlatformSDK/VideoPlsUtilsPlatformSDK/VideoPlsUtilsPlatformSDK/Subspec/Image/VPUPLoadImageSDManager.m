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
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageDownloader.h>

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

//3.8.0
typedef void(^progressBlock)(NSInteger receivedSize,NSInteger expectedSize);
typedef void(^completed)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL);

//4.2.2 5.0.0
typedef void(^downloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^internalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

static NSSDWebImageManager* webImageManager() {
    static NSSDWebImageManager *webImageManager = nil;
    
    if(!webImageManager) {
        NSSDImageCache *imageCache = [[NSSDImageCache alloc]initWithNamespace:@"videopls"];
        NSSDWebImageDownloader *imageDownloader = [[NSSDWebImageDownloader alloc] init];
        
        //5.0.1
        SEL loader = @selector(initWithCache:loader:);
        
        //3.8.8  4.0.0
        SEL downloader = @selector(initWithCache:downloader:);
        
        //5.0.1
        if ([NSSDWebImageManager instanceMethodSignatureForSelector:loader] != nil) {
            
            NSSDWebImageManager * manager = [[NSSDWebImageManager alloc]init];
            IMP imp = [manager methodForSelector:loader];
            SDWebImageManager * (*func)(id,SEL,SDImageCache *,SDWebImageDownloader *) = (void *)imp;
            webImageManager = func(manager,loader,imageCache,imageDownloader);
            
            //3.8.8  4.0.0
        }else if ([NSSDWebImageManager instanceMethodSignatureForSelector:downloader] != nil) {
            
            NSSDWebImageManager * manager = [[NSSDWebImageManager alloc]init];
            IMP imp = [manager methodForSelector:downloader];
            SDWebImageManager * (*func)(id,SEL,SDImageCache *,SDWebImageDownloader *) = (void *)imp;
            webImageManager = func(manager,downloader,imageCache,imageDownloader);
        }
        
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

@interface VPUPLoadImageSDManager()

@property(copy,nonatomic) progressBlock                 progressblock;
@property(copy,nonatomic) completed                     completedblock;
@property(copy,nonatomic) downloaderProgressBlock       downloaderProgressBlock;
@property(copy,nonatomic) internalCompletionBlock       internalCompletionBlock;
@end

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
    
    //4.2.2  5.0.0
    self.downloaderProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (blockConfig.progressBlock) {
            blockConfig.progressBlock(receivedSize, expectedSize);
        }
    };
    self.internalCompletionBlock = ^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
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
                
                if (data != nil) {
                    [sself setImage:image imageData:data view:sview config:blockConfig];
                }else {
                    NSData * imageData = [sself cachePathForKeyinURL:url];
                    [sself setImage:image imageData:imageData view:sview config:blockConfig];
                }
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
        
    };
    
    //3.8.0
    self.progressblock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        if (blockConfig.progressBlock) {
            blockConfig.progressBlock(receivedSize, expectedSize);
        }
    };
    self.completedblock = ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
                
                [sself setImage:image imageData:UIImagePNGRepresentation(image) view:sview config:blockConfig];
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
    };
    
    
    SEL downloadImageWithURL = @selector(downloadImageWithURL:options:progress:completed:);
    
    SEL loadImageWithURL = @selector(loadImageWithURL:options:progress:completed:);
    
    //3.8.0
    if ([[webImageManager() class] instanceMethodSignatureForSelector:downloadImageWithURL] != nil) {
        
        IMP imp = [webImageManager() methodForSelector: downloadImageWithURL];
        id (*func)(id,SEL,NSURL*,SDWebImageOptions,progressBlock,completed) = (void *)imp;
        id <SDWebImageOperation> operation = func(webImageManager(),
                                                  downloadImageWithURL,
                                                  url,
                                                  options,
                                                  self.progressblock,
                                                  self.completedblock
                                                  );
        [view sd_setImageLoadOperation:operation forKey:validOperationKey];
        
        //4.2.2  5.0.1
    }else if ([[webImageManager() class] instanceMethodSignatureForSelector:loadImageWithURL] != nil) {
        
        IMP imp = [webImageManager() methodForSelector: loadImageWithURL];
        
        id (*func)(id,SEL,NSURL*,SDWebImageOptions,downloaderProgressBlock,internalCompletionBlock) = (void *)imp;
        id <SDWebImageOperation> operation = func(webImageManager(),
                                                  loadImageWithURL,
                                                  url,
                                                  options,
                                                  self.downloaderProgressBlock,
                                                  self.internalCompletionBlock
                                                  );
        [view sd_setImageLoadOperation:operation forKey:validOperationKey];
    }
    
}

- (NSData * _Nullable)cachePathForKeyinURL:(nullable NSURL *)url {
    
    NSString * key = [webImageManager() cacheKeyForURL:url];
    
    NSData * iamgeData = nil;
    if (key.length > 0) {
        NSSDImageCache *imageCache = [[NSSDImageCache alloc]initWithNamespace:@"videopls"];
        
        SEL cachePath = @selector(cachePathForKey:);
        SEL defaultCachePath = @selector(defaultCachePathForKey:);
        
        if ([[imageCache class] instanceMethodSignatureForSelector:cachePath] != nil) {
            IMP imp = [imageCache methodForSelector:cachePath];
            NSString *(*func)(id,SEL,NSString *) = (void *)imp;
            NSString * filePath = func(imageCache,cachePath,key);
            iamgeData = [NSData dataWithContentsOfFile:filePath];
            //            NSLog(@"filePath:  %@",filePath);
            
        }else if ([[imageCache class] instanceMethodSignatureForSelector:defaultCachePath] != nil) {
            IMP imp = [imageCache methodForSelector:defaultCachePath];
            NSString *(*func)(id,SEL,NSString *) = (void *)imp;
            NSString * filePath = func(imageCache,defaultCachePath,key);
            iamgeData = [NSData dataWithContentsOfFile:filePath];
            //            NSLog(@"filePath:  %@",filePath);
        }
        
    }
    return iamgeData;
}


#endif

- (void)clearMemory {
    SDImageCache * cache = [webImageManager() imageCache];
    [cache clearMemory];
    
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
//                        [webImageManager().imageCache clearMemory];
                        SDImageCache * cache = [webImageManager() imageCache];
                        [cache clearMemory];
                    }
                    if(loopCompleteBlock) {
                        loopCompleteBlock(loopCountRemaining);
                    }
                };
            }
            else {
                //4.2.2 5.0.0
                SEL imageFormatForImag = @selector(sd_imageFormatForImageData:);
                //3.8.0
                SEL contentTypeForImage = @selector(sd_contentTypeForImageData:);
                
                //4.2.2  5.0.0
                if ([NSData methodSignatureForSelector:imageFormatForImag] != nil) {
                    
                    IMP imp = [NSData methodForSelector:imageFormatForImag];
                    NSInteger *(*func)(id,SEL,NSData*) = (void *)imp;
                    NSInteger *integer = func([NSData class],imageFormatForImag,data);
                    
                    if ((int)integer == 2) {
                        imageView.animatedImage = [VPUPFLAnimatedImage animatedImageWithGIFData:data];
                        imageView.image = nil;
                    }else {
                        imageView.image = image;
                        imageView.animatedImage = nil;
                    }
                    
                    //3.8.0
                }else if ([NSData methodSignatureForSelector:contentTypeForImage] != nil) {
                    IMP imp = [NSData methodForSelector:contentTypeForImage];
                    NSString *(*func)(id,SEL,NSData*) = (void *)imp;
                    NSString *imageName = func([NSData class],contentTypeForImage,data);
                    
                    if ([imageName isEqualToString:@"image/gif"]) {
                        imageView.animatedImage = [VPUPFLAnimatedImage animatedImageWithGIFData:data];
                        imageView.image = nil;
                    }else {
                        imageView.image = image;
                        imageView.animatedImage = nil;
                    }
                    
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
