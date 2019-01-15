//
//  VPUPUIWebViewJSBridge.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 12/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VPUPWKWebViewJSBridge.h"

@interface VPUPUIWebViewJSBridge : NSObject<UIWebViewDelegate>

@property (nonatomic, weak) id<UIWebViewDelegate> webViewDelegate;
@property (nonatomic, weak) UIWebView *webView;

+ (instancetype)bridgeForWebView:(UIWebView*)webView;

+ (instancetype)bridgeForWebView:(UIWebView*)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate;

- (instancetype)initWithWebView:(UIWebView*)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithWebView:webViewDelegate: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithWebView:webViewDelegate: instead.
+ (instancetype)new NS_UNAVAILABLE;

- (void)registerHandler:(NSString *)handlerName handler:(VPUPWVJBHandler)handler;

- (void)nativeCallWebviewWithJS:(NSString *)javaScriptString completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler;

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler;

@end
