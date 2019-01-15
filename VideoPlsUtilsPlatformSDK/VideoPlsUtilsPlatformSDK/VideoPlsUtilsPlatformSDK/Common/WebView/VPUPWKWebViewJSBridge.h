//
//  VPUPWKWebViewJSBridge.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 12/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol VPUPWKWebViewDelegate;

typedef void (^VPUPWVJBResponseCallback)(id responseData);
typedef void (^VPUPWVJBHandler)(id data, VPUPWVJBResponseCallback responseCallback);
typedef void (^VPUPWVJBNativeCallJSCompletionHandler)(id data, NSError *error);

@interface VPUPWKWebViewJSBridge : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
@property (nonatomic, weak) id<VPUPWKWebViewDelegate> webView;
@property (nonatomic, copy) NSString *messageName;

+ (instancetype)bridgeForWebView:(id<VPUPWKWebViewDelegate>)webView;

+ (instancetype)bridgeForWebView:(id<VPUPWKWebViewDelegate>)webView scriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

- (instancetype)initWithWebView:(id<VPUPWKWebViewDelegate>)webView scriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithWebView:scriptDelegate: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithWebView:scriptDelegate: instead.
+ (instancetype)new NS_UNAVAILABLE;

- (void)registerHandler:(NSString *)handlerName handler:(VPUPWVJBHandler)handler;

- (void)nativeCallWebviewWithJS:(NSString *)javaScriptString completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler;

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler;

@end
