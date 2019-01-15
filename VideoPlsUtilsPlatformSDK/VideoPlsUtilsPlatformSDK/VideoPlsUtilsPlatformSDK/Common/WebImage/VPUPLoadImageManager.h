//
//  VPUPWebImageProtocol.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPLoadImageBaseConfig;
@class VPUPLoadImageButtonConfig;

@protocol VPUPLoadImageManager <NSObject>

/**
 *  加载GIF的ImageView需继承或者使用VPUPFLAnimatedImageView,否则GIF图片不会动
 */

- (void)loadImageWithConfig:(VPUPLoadImageBaseConfig *)config;

- (void)loadImageWithButtonConfig:(VPUPLoadImageButtonConfig *)config;

- (void)clearMemory;

- (void)prefetchURLs:(NSArray<NSString *> *)urls;

- (void)prefetchURLs:(NSArray<NSString *> *)urls
     completionBlock:(void(^)(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls))completionBlock;

- (void)cancelPrefetching;

@end

