//
//  VPUPPrefetchVideoManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPPrefetchVideoManager.h"
#import "VPUPFileHandle.h"
#import "VPUPMD5Util.h"
#import "VPUPPathUtil.h"

@implementation VPUPPrefetchVideoManager

- (instancetype)init {
    self = [super init];
    if(self) {
        self.maxConcurrentDownloads = 1;
    }
    return self;
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls {
    if (urls && urls.count == 0) {
        return;
    }
    NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:0];
    for (NSString *urlString in urls) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *fileName = [NSString stringWithFormat:@"%@.%@",[VPUPMD5Util md5HashString:url.absoluteString],[url pathExtension]];
        [fileNames addObject:fileName];
    }
    
    NSString *destinationPath = [VPUPPathUtil pathByPlaceholder:@"videoAds"];
    [self prefetchURLs:urls fileNames:fileNames destinationPath:destinationPath];
}

@end
