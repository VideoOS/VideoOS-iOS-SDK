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
#import "VPUPUrlUtil.h"

@implementation VPUPPrefetchVideoManager

- (instancetype)init {
    self = [super init];
    if(self) {
        self.maxConcurrentDownloads = 1;
    }
    return self;
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls {
    [self prefetchURLs:urls complete:nil];
}

- (void)prefetchURLs:(NSArray<NSString *> *)urls complete:(VPUPPrefetchTrafficCompletionBlock)complete {
    
    if (urls && urls.count == 0) {
        [self callCompleteBlock:complete trafficList:nil];
        return;
    }
    
    NSString *destinationPath = [VPUPPathUtil pathByPlaceholder:@"videoAds"];
    
    NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *encodeUrls = [NSMutableArray arrayWithCapacity:0];
    for (NSString *urlString in urls) {
//        NSString *urlEncodeString = [VPUPUrlUtil urlencode:urlString];
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            NSString *fileName = [NSString stringWithFormat:@"%@.%@",[VPUPMD5Util md5HashString:url.absoluteString],[url pathExtension]];
            NSString *filePath = [destinationPath stringByAppendingPathComponent:fileName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                continue;
            }
            
            [fileNames addObject:fileName];
            [encodeUrls addObject:urlString];
        }
    }
    
    
    [self prefetchURLs:encodeUrls fileNames:fileNames destinationPath:destinationPath completionBlock:^(NSUInteger numberOfFinishedUrls, NSUInteger numberOfSkippedUrls) {
        
        VPUPTrafficStatisticsList *list = [[VPUPTrafficStatisticsList alloc] init];
        for (NSInteger i = 0; i < fileNames.count; i++) {
            NSString *fileName = [fileNames objectAtIndex:i];
            NSString *url = [encodeUrls objectAtIndex:i];
            NSString *filePath = [destinationPath stringByAppendingPathComponent:fileName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [list addFileTrafficByName:fileName fileUrl:url filePath:filePath];
            }
        }
        
        [self callCompleteBlock:complete trafficList:list];
        
    }];
    
}

- (void)callCompleteBlock:(VPUPPrefetchTrafficCompletionBlock)completeBlock trafficList:(VPUPTrafficStatisticsList *)trafficList {
    
    if (!completeBlock) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completeBlock(trafficList);
    });
    
}

@end
