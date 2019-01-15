//
//  VPUPUIWebViewJSBridge.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 12/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPUIWebViewJSBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface VPUPUIWebViewJSBridge ()

@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSMutableDictionary *messageHandlers;

@end

@implementation VPUPUIWebViewJSBridge

+ (instancetype)bridgeForWebView:(UIWebView*)webView {
    return [self bridgeForWebView:webView webViewDelegate:nil];
}

+ (instancetype)bridgeForWebView:(UIWebView*)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate {
    return [[self alloc] initWithWebView:webView webViewDelegate:webViewDelegate];
}

- (instancetype)initWithWebView:(UIWebView*)webView webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate {
    self = [super init];
    if (self) {
        _webView = webView;
        _webView.delegate = self;
        _webViewDelegate = webViewDelegate;
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerHandler:(NSString *)handlerName handler:(VPUPWVJBHandler)handler {
    _messageHandlers[handlerName] = [handler copy];
}

- (void)nativeCallWebviewWithJS:(NSString *)javaScriptString completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler {
    [_jsContext evaluateScript:javaScriptString];
}

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params completionHandler:(VPUPWVJBNativeCallJSCompletionHandler)completionHandler {
    JSValue *callJS = _jsContext[jsFuncName];
    if (callJS) {
        [callJS callWithArguments:params];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    @try {
        self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
            context.exception = exceptionValue;
            NSLog(@"异常信息：%@", exceptionValue);
        };
        
        [_messageHandlers enumerateKeysAndObjectsUsingBlock:^(NSString *key, VPUPWVJBHandler obj, BOOL *stop) {
            self.jsContext[key] = obj;
        }];
    } @catch (NSException *exception) {
        NSLog(@"异常信息：%@", exception);
    }
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewDelegate webView:webView didFailLoadWithError:error];
    }
}

@end
