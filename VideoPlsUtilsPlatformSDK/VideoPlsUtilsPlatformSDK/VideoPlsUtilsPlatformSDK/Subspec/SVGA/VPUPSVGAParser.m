//
//  VPUPSVGAParser.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2018/3/30.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPUPSVGAParser.h"
#import "VideoPlsUtilsPlatformSDK.h"

@interface VPUPSVGAParser ()

- (nonnull NSString *)cacheKey:(NSURL *)URL;

@end

@implementation VPUPSVGAParser

- (nullable NSString *)cacheDirectory:(NSString *)cacheKey {
     NSString *cacheDir = [VPUPPathUtil pathByPlaceholder:@"svga"];
    return [cacheDir stringByAppendingFormat:@"/%@", cacheKey];
}

- (void)parseWithURL:(nonnull NSURL *)URL
     completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock
        failureBlock:(void ( ^ _Nullable)(NSError * _Nullable error))failureBlock {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory:[self cacheKey:URL]]]) {
        [self parseWithData:[NSData dataWithContentsOfFile:[self cacheDirectory:[self cacheKey:URL]]] cacheKey:[self cacheKey:URL] completionBlock:completionBlock failureBlock:failureBlock];
        return;
    }
    
    VPUPDownloadRequest *request = [[VPUPDownloadRequest alloc] initWithDownloadUrl:URL.absoluteString destination:[self cacheDirectory:[self cacheKey:URL]] progress:nil completionHandler:^(NSURL *filePath, NSError *error) {
        if (!error) {
            [self parseWithData:[NSData dataWithContentsOfFile:[self cacheDirectory:[self cacheKey:URL]]] cacheKey:[self cacheKey:URL] completionBlock:completionBlock failureBlock:failureBlock];
        }
        else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
    [[VPUPDownloaderManager sharedManager] downloadWithRequest:request];
}

@end
