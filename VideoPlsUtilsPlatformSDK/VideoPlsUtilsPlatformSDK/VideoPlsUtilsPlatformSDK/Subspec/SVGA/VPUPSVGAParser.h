//
//  VPUPSVGAParser.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2018/3/30.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import <SVGAPlayer/SVGAParser.h>

@interface VPUPSVGAParser : SVGAParser

- (nullable NSString *)cacheDirectory:(NSString *)cacheKey;

- (void)parseWithURL:(nonnull NSURL *)URL
     completionBlock:(void ( ^ _Nonnull )(SVGAVideoEntity * _Nullable videoItem))completionBlock
        failureBlock:(void ( ^ _Nullable)(NSError * _Nullable error))failureBlock;
@end
