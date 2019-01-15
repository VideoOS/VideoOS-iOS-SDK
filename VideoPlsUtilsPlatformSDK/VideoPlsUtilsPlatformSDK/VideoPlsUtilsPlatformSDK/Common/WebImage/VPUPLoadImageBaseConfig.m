//
//  VPUPLoadImageBaseConfig.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPLoadImageBaseConfig.h"
#import "VPUPLoadImageWebPURL.h"

@implementation VPUPLoadImageBaseConfig

- (instancetype)init {
    self = [super init];
    if(self) {
        _placeholderContentMode = UIViewContentModeCenter;
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view url:(NSURL *)url completionHandle:(VPUPLoadImageCompletionBlock)completionHandler {
    self = [self init];
    if(self) {
        _view = view;
        _url = url;
        _completedBlock = completionHandler;
    }
    return self;
}

- (void)setPlaceholder:(UIImage *)placeholder {
    if ([placeholder isKindOfClass:[UIImage class]]) {
        _placeholder = placeholder;
    }
}

- (void)setPlaceholderBackgroundColor:(UIColor *)placeholdeBackgroundColor {
    if ([placeholdeBackgroundColor isKindOfClass:[UIColor class]]) {
        _placeholderBackgroundColor = placeholdeBackgroundColor;
    }
}

- (NSURL *)getWebPURL {
    return [VPUPLoadImageWebPURL webPURLFromURL:_url];
}


@end
