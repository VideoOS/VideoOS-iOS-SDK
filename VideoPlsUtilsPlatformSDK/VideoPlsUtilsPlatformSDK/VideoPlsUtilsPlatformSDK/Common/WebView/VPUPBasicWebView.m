//
//  VPUPBasicWebView.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 22/05/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import "VPUPBasicWebView.h"
#import "VPUPWebView.h"
#import "VPUPWKWebView.h"
#import "VPUPExtendWKWebView.h"

#define rectStatusBar       [UIApplication sharedApplication].statusBarFrame.size.height
#define kDeviceHeight       [UIScreen mainScreen].bounds.size.height
#define kDeviceWidth        [UIScreen mainScreen].bounds.size.width
#define kVideoAreaHeight    kDeviceWidth / 16 * 9
#define screenScale         kDeviceWidth / 414

#ifndef ISIPHONE8
#define ISIPHONE8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0))
#endif

@interface VPUPBasicWebView()<VPUPWebViewDelegate>

@property (nonatomic, strong) VPUPWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *loadTimer;

@end

@implementation VPUPBasicWebView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame url:nil];
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url {
    return [self initWithFrame:frame url:url jsCallOCDictionary:nil];
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url jsCallOCDictionary:(NSDictionary<NSString *,VPUPWebViewCallback> *)JSCallOCDictionary {
    self = [super initWithFrame:frame];
    if (self) {
        _webView = [VPUPWebView initWebViewWithFrame:self.bounds];
        _webView.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        [_progressView setTrackTintColor:[UIColor clearColor]];
//        [_progressView setTintColor:[VPUPHXColor vpup_colorWithHexARGBString:@"FFE9595E"]];
        [_progressView setHidden:YES];
        _webView.delegate = self;
        [self addSubview:_webView.webView];
        [self addSubview:_progressView];
        if(url) {
            [self loadUrl:url];
        }
        _JSCallOCDict = JSCallOCDictionary;
        _webView.JSCallOCDict = JSCallOCDictionary;
    }
    return self;
}

- (void)setProgressColor:(UIColor *)color {
    if(_progressView) {
        [_progressView setTintColor:color];
    }
}

- (void)setDisableNativePayment:(BOOL)disableNativePayment {
    _disableNativePayment = disableNativePayment;
    if(_webView) {
        _webView.disableNativePayment = disableNativePayment;
    }
}

- (void)setJSCallOCDict:(NSDictionary<NSString *,VPUPWebViewCallback> *)JSCallOCDict {
    if(JSCallOCDict) {
        _JSCallOCDict = JSCallOCDict;
        _webView.JSCallOCDict = JSCallOCDict;
    }
}

- (void)addJSBridge:(VPUPWKWebViewJSBridge *)jsBridge {
    if (!jsBridge) {
        return;
    }
    if ([jsBridge.messageName isEqualToString:@"Native"]) {
        return;
    }
    jsBridge.webView = _webView.webView;
    [((VPUPExtendWKWebView *)_webView.webView) addScriptMessageHandler:jsBridge name:jsBridge.messageName];
}

- (void)loadUrl:(NSString *)url {
    if(url) {
        if([_linkUrl isEqualToString:url]) {
            return;
        }
        _linkUrl = url;
//        [self stopTimer];
        if([url isEqualToString:@""]) {
            [_webView startLoadingWithHtmlString:@""];
        } else {
            [_webView startLoadingWithUrl:_linkUrl];
        }
    }
}

- (void)updateWebViewFrame:(CGRect)frame {
    [_webView setFrame:self.bounds];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
//    [self updateWebViewFrame:frame];
    [_progressView setFrame:CGRectMake(0, 0, frame.size.width, 1)];
}

- (BOOL)canGoBack {
    return [_webView canGoBack];
}

- (void)goBack {
    [_webView goBack];
}

- (void)stop {
    [_webView stop];
    [_webView removeCache];
    if(_loadTimer) {
        [_loadTimer invalidate];
        _loadTimer = nil;
    }
}

- (void)stopAndRemoveBasicWebview {
    [_webView stop];
    [_webView removeCache];
    if(_loadTimer) {
        [_loadTimer invalidate];
        _loadTimer = nil;
    }
    
    [self removeFromSuperview];
}

- (void)updateProgress {
    CGFloat progress = [_webView progress];
    if(progress < 0) {
        progress = 0;
    }
    if(progress > 1) {
        progress = 1;
    }
    [_progressView setProgress:progress];
}

- (void)startTimer {
    [_progressView setHidden:NO];
    if(!_loadTimer) {
        _loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    
}

- (void)stopTimer {
    [_progressView setHidden:YES];
    [_progressView setProgress:0];
    [_loadTimer invalidate];
    _loadTimer = nil;
}

- (void)setLandscape:(BOOL)landscape {
    _landscape = landscape;
    _webView.landscape = landscape;
}

#pragma VPUPWebViewDelegate
- (void)loadCompleteTitle:(NSString *)title error:(NSError *)error {
    [self stopTimer];
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteWithTitle:error:)]) {
            [self.delegate loadCompleteWithTitle:title error:error];
        }
    }
}

- (void)didStartLoad {
    [self startTimer];
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(webViewDidStartLoad)]) {
            [self.delegate webViewDidStartLoad];
        }
    }
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback {
    if (ISIPHONE8) {
        [((VPUPWKWebView *)_webView) nativeCallWebviewWithJS:jsFuncName paramaters:params callback:callback];
    }
}

@end
