//
//  VPUPWKWebView.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 16/10/10.
//  Copyright © 2016年 videopls.com. All rights reserved.
//

#import <Availability.h>
#import "VPUPGeneralInfo.h"
#import "VPUPServiceManager.h"
#import "VPUPWKWebViewDelegate.h"

#ifdef __IPHONE_8_0
@import WebKit;
#endif

//#ifndef IS_OS_9_OR_LATER
//#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
//#endif

#import "VPUPWKWebView.h"

#import "VPUPLogUtil.h"
#import "VPUPWKWebViewJSBridge.h"
#import "VPUPExtendWKWebView.h"

@interface VPUPWKWebView() <WKNavigationDelegate,WKUIDelegate>

//@property (nonatomic) WKWebView *webView;
@property (nonatomic) NSDate *loadDate;
@property (nonatomic) VPUPWKWebViewJSBridge *jsBridge;
@property (nonatomic) UIView<VPUPWKWebViewDelegate> *webView;

@end

@implementation VPUPWKWebView
@synthesize webView = _webView;

+ (void)initialize {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPWKWebViewDelegate) implClass:[VPUPExtendWKWebView class]];
}

- (void)setUpWebViewWithFrame:(CGRect)frame {
    
    _webView = (UIView<VPUPWKWebViewDelegate>*)[[VPUPServiceManager sharedManager] createService:@protocol(VPUPWKWebViewDelegate)];
    _webView.frame = frame;
    
    _jsBridge = [VPUPWKWebViewJSBridge bridgeForWebView:_webView scriptDelegate:nil];
    _jsBridge.messageName = @"Native";
    [_webView addScriptMessageHandler:_jsBridge name:_jsBridge.messageName];
    _webView.navigationDelegate = self;
    
    if (@available(iOS 11.0, *)) {
        //竖屏自动兼容
        [_webView setIsLandscape:self.isLandscape];
    }
}

- (void)setJSCallOCDict:(NSDictionary<NSString *,VPUPWebViewCallback> *)dict {
    super.JSCallOCDict = dict;
    if (dict) {
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, VPUPWebViewCallback obj, BOOL *stop) {
            [_jsBridge registerHandler:key handler:^(id data, VPUPWVJBResponseCallback responseCallback){
                obj(data);
            }];
        }];
    }
}

- (void)setZoomScale:(double)scale {
    [_webView setZoomScale:scale];
}

- (void)startLoadingWithUrl:(NSString *)url {
    _loadDate = [NSDate date];
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

- (void)stop {
    [_webView stopLoading];
    [_webView removeFromSuperview];
    self.JSCallOCDict = nil;
    _webView.navigationDelegate = nil;
}

- (void)dealloc {
    [_webView removeScriptMessageHandlerForName:_jsBridge.messageName];
}

- (CGFloat)progress {
    return [_webView estimatedProgress];
}

- (void)setFrame:(CGRect)frame {
    [_webView setFrame:frame];
}

- (void)removeCache {
    [super removeCache];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (@available(iOS 9.0, *)) {
        NSSet *websiteDataTypes
        = [NSSet setWithArray:@[
                                WKWebsiteDataTypeDiskCache,
                                WKWebsiteDataTypeOfflineWebApplicationCache,
                                WKWebsiteDataTypeMemoryCache,
                                WKWebsiteDataTypeLocalStorage,
                                WKWebsiteDataTypeCookies,
                                WKWebsiteDataTypeSessionStorage,
                                WKWebsiteDataTypeIndexedDBDatabases,
                                WKWebsiteDataTypeWebSQLDatabases
                                ]];
        //// All kinds of data
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        //// Date from
        NSDate *dateFrom = _loadDate;
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
        }];
    }
    
}

- (void)setLandscape:(BOOL)isLandscape {
    [super setLandscape:isLandscape];
    [_webView setIsLandscape:isLandscape];
}


#pragma WeKitDelegate

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(didStartLoad)]) {
            [self.delegate didStartLoad];
        }
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *requestURL = navigationAction.request.URL;
    BOOL needOpenDeepLink = NO;
    
    if (requestURL.scheme) {
        //排除http
        if ([requestURL.scheme rangeOfString:@"http"].location == NSNotFound) {
            //排除支付宝，微信？？怎么知道支付宝微信一定是付款？
            if ([requestURL.scheme rangeOfString:@"alipay"].location != NSNotFound
                || [requestURL.scheme rangeOfString:@"weixin"].location != NSNotFound) {
                if (!self.disableNativePayment) {
                    //需要拉起支付宝、微信
                    needOpenDeepLink = YES;
                }
            } else {
                //其他的应用
                if (!self.disableDeepLink) {
                    needOpenDeepLink = YES;
                }
            }
        }
    }
    
    if (needOpenDeepLink) {
        UIApplication *application = [UIApplication sharedApplication];
        if([application canOpenURL:requestURL]) {
            if (@available(iOS 10.0, *)) {
                [application openURL:requestURL options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:^(BOOL success) {
                    
                }];
            } else {
                [application openURL:requestURL];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}
//
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    decisionHandler(WKNavigationResponsePolicyAllow);
//}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation  {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteTitle:error:)]) {
            NSString *title = webView.title;
            [self.delegate loadCompleteTitle:title error:nil];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteTitle:error:)]) {
            NSString *title = webView.title;
            [self.delegate loadCompleteTitle:title error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(loadCompleteTitle:error:)]) {
            NSString *title = webView.title;
            [self.delegate loadCompleteTitle:title error:error];
        }
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback {
    [_jsBridge nativeCallWebviewWithJS:jsFuncName paramaters:params completionHandler:^(id data, NSError *error){
        if(callback) {
            if (error) {
                callback(error);
                return ;
            }
            callback(data);
        }
    }];
}


@end
