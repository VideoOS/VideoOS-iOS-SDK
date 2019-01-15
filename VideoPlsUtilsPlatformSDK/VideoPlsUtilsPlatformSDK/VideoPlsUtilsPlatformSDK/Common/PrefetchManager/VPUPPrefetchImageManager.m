//
//  VPUPPrefetchImageManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPPrefetchImageManager.h"
#import "VPUPLoadImageManager.h"
#import "VPUPLoadImageFactory.h"
#import "VPUPLoadImageWebPURL.h"

@interface VPUPPrefetchImageManager()

@end

@implementation VPUPPrefetchImageManager {
    id<VPUPLoadImageManager> _imageManager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _imageManager = [VPUPLoadImageFactory createWebImageManagerWithType:VPUPWebImageManagerTypeSD];
    }
    return self;
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls {
    [self prefetchURLs:urls fileNames:nil destinationPath:nil completionBlock:nil];
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls completionBlock:(VPUPPrefetcherCompletionBlock)completionBlock {
    [self prefetchURLs:urls fileNames:nil destinationPath:nil completionBlock:completionBlock];
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls
           fileNames:(NSArray<NSString *> *)fileNames
     destinationPath:(NSString *)destinationPath
     completionBlock:(VPUPPrefetcherCompletionBlock)completionBlock {
    
    [_imageManager prefetchURLs:urls completionBlock:completionBlock];

}

- (void)cancelPrefetch {
    [_imageManager cancelPrefetching];
}

@end
