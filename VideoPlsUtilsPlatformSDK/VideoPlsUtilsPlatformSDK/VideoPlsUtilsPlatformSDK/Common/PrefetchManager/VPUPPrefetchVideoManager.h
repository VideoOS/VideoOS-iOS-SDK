//
//  VPUPPrefetchVideoManager.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/8.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPUPPrefetchManager.h"

@interface VPUPPrefetchVideoManager : VPUPPrefetchManager

- (void)prefetchURLs:(NSArray<NSString *> *)urls;

- (void)prefetchURLs:(NSArray<NSString *> *)urls complete:(VPUPPrefetchTrafficCompletionBlock)complete;

@end
