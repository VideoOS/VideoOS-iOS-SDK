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

@interface VPUPWebView()<UIWebViewDelegate,VPUPJSExport>

@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSURLCache *sharedCache;

@end

@implementation VPUPWebView

+ (VPUPWebView *)initWebViewWithFrame:(CGRect)frame {
    VPUPWebView *webView;
    if(ISIPHONE8) {
        webView = [[VPUPWKWebView alloc] initWithFrame:frame];
    }else {
        webView = [[VPUPWebView alloc] initWithFrame:frame];
    }
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
    _webView = [[UIWebView alloc] initWithFrame:frame];
    _webView.delegate = self;
    [_webView setAllowsInlineMediaPlayback:YES];
    [_webView setScalesPageToFit:YES];
//    [self addSubview:webview];
}

- (void)setUpCache {
    _sharedCache = [NSURLCache sharedURLCache];
    
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    _cache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"VPUPURLCache"];
    [NSURLCache setSharedURLCache:_cache];
    
}


- (void)startLoadingWithUrl:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0];
    [_webView loadRequest:request];
}

- (void)startLoadingWithHtmlString:(NSString *)htmlString {
    [_webView loadHTMLString:htmlString baseURL:nil];
}

- (BOOL)canGoBack {
    return [_webView canGoBack];
}

- (void)goBack {
    [_webView goBack];
}

- (void)setFrame:(CGRect)frame {
    [_webView setFrame:frame];
}

- (CGFloat)progress {
    //UIWebView没有
    return 0.8;
}

- (void)stop {
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView reload];
    [_webView stopLoading];
    _webView.delegate = nil;
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


#pragma WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteTitle:error:)]) {
            NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            [self.delegate loadCompleteTitle:title error:nil];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteTitle:error:)]) {
            [self.delegate loadCompleteTitle:nil error:error];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(didStartLoad)]) {
            [self.delegate didStartLoad];
        }
    }
}

#pragma mark - JSExport Methods -- Javascript call Native
- (void)handleJavascriptAPIWithDict:(NSDictionary *)dict {
    
}

- (void)nativeCallJS {
    NSMutableArray *arrayToCall = [NSMutableArray array];
    [arrayToCall addObject:@1];
    [arrayToCall addObject:@2];
    // native call js with argus
    [self.context[@"getNTShoppingCart"] callWithArguments:arrayToCall];
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback {
    
}

@end
