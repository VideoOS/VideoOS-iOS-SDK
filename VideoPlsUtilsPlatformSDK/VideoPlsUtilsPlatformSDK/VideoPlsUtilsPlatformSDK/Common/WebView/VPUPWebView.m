//
//  VPUPWebView.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 16/10/10.
//  Copyright © 2016年 videopls.com. All rights reserved.
//

#import "VPUPWebView.h"
#import "VPUPWKWebView.h"

//#ifdef __IPHONE_8_0
//#define ISIPHONE8 1
//#else
//#define ISIPHONE8 0
//#endif

#ifndef ISIPHONE8
#define ISIPHONE8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0))
#endif

@interface VPUPWebView()<VPUPJSExport>

@property (nonatomic) NSURLCache *sharedCache;

@end

@implementation VPUPWebView

+ (VPUPWebView *)initWebViewWithFrame:(CGRect)frame {
    VPUPWebView *webView;
    webView = [[VPUPWKWebView alloc] initWithFrame:frame];
    return webView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if(self) {
        [self setUpWebViewWithFrame:frame];
    }
    return self;
}

- (void)setUpWebViewWithFrame:(CGRect)frame {
    
}

- (void)setUpCache {
    _sharedCache = [NSURLCache sharedURLCache];
    
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    _cache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"VPUPURLCache"];
    [NSURLCache setSharedURLCache:_cache];
}


- (void)startLoadingWithUrl:(NSString *)url {
    
}

- (void)startLoadingWithHtmlString:(NSString *)htmlString {
    
}

- (BOOL)canGoBack {
    return NO;
}

- (void)goBack {
    
}

- (void)setFrame:(CGRect)frame {
    [_webView setFrame:frame];
}

- (CGFloat)progress {
    //UIWebView没有
    return 0.8;
}

- (void)stop {
    
    [_webView removeFromSuperview];
    
    _webView = nil;
    self.delegate = nil;
}

- (void)removeCache {
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    [NSURLCache setSharedURLCache:_sharedCache];
    
    _cache = nil;
    _sharedCache = nil;
}

#pragma mark - JSExport Methods -- Javascript call Native
- (void)handleJavascriptAPIWithDict:(NSDictionary *)dict {
    
}

- (void)nativeCallJS {
//    NSMutableArray *arrayToCall = [NSMutableArray array];
//    [arrayToCall addObject:@1];
//    [arrayToCall addObject:@2];
//    // native call js with argus
//    [self.context[@"getNTShoppingCart"] callWithArguments:arrayToCall];
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback {
    
}

@end
