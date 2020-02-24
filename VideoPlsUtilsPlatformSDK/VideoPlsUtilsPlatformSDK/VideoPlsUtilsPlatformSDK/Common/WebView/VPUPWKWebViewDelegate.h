//
//  VPUPWKWebViewDelegate.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VPUPWKWebViewDelegate <NSObject>

/*! @abstract The web view's navigation delegate. */
@property (nullable, nonatomic, weak) id <WKNavigationDelegate> navigationDelegate;

//添加WKScriptMessageHandler
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;

- (void)removeScriptMessageHandlerForName:(NSString *)name;

- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request;

- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

@property (nonatomic, readonly) BOOL canGoBack;

@property (nonatomic, readonly) BOOL canGoForward;

@property (nonatomic, readonly) double estimatedProgress;

- (nullable WKNavigation *)goBack;

- (nullable WKNavigation *)goForward;

- (nullable WKNavigation *)reload;

- (void)stopLoading;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

- (void)setIsLandscape:(BOOL)isLandscape;

- (void)setZoomScale:(double)scale;

@end

NS_ASSUME_NONNULL_END
