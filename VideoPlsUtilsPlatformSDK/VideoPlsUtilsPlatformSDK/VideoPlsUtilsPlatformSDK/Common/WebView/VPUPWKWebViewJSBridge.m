//
//  VPUPWKWebViewJSBridge.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 12/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPWKWebViewJSBridge.h"
#import "VPUPLogUtil.h"
#import "VPUPWKWebViewDelegate.h"

@interface VPUPWKWebViewJSBridge ()

@property (nonatomic, strong) NSMutableDictionary *messageHandlers;

@end

@implementation VPUPWKWebViewJSBridge

+ (instancetype)bridgeForWebView:(id<VPUPWKWebViewDelegate>)webView {
    return [self bridgeForWebView:webView scriptDelegate:nil];
}

+ (instancetype)bridgeForWebView:(id<VPUPWKWebViewDelegate>)webView scriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    return [[self alloc] initWithWebView:webView scriptDelegate:scriptDelegate];
}

- (instancetype)initWithWebView:(id<VPUPWKWebViewDelegate>)webView scriptDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _scriptDelegate = scriptDelegate;
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:self.messageName] && message.body) {
        NSDictionary *body = message.body;
        NSString *method = [body objectForKey:@"method"];
        NSString *args = [body objectForKey:@"args"];

        VPUPWVJBHandler callBack = [_messageHandlers objectForKey:method];
        if(callBack) {
            callBack(args,nil);
            return;
        }
    }
    
    if (self.scriptDelegate && [self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

- (void)registerHandler:(NSString *)handlerName handler:(VPUPWVJBHandler)handler {
    _messageHandlers[handlerName] = [handler copy];
}

- (void)nativeCallWebviewWithJS:(NSString *)javaScriptString completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler {
    [_webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            VPUPLogWR(@"[WebView call JS error], %@", error);
        }
        if(completionHandler) {
            completionHandler(result, error);
        }
    }];
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler {
    
    NSString *jsCode = [NSString stringWithFormat:@"%@()",jsFuncName];
    if (params && params.count > 0) {
        jsCode = [NSString stringWithFormat:@"%@(",jsFuncName];
        for (NSString *param in params) {
            jsCode = [jsCode stringByAppendingFormat:@"'%@'",param];
        }
        jsCode = [jsCode stringByAppendingString:@")"];
    }
    
    [_webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            VPUPLogWR(@"[WebView call JS error], %@", error);
        }
        if(completionHandler) {
            completionHandler(result, error);
        }
    }];
}

@end
