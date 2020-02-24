//
//  VPUPWebView.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 16/10/10.
//  Copyright © 2016年 videopls.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef void (^VPUPWebViewCallback)(id result);
@protocol VPUPWebViewDelegate <NSObject>
@optional
- (void)loadCompleteTitle:(NSString *)title error:(NSError *)error;
- (void)didStartLoad;

- (void)getUserInfo;
//- (void)getShoppingCart;

@end

@protocol VPUPJSExport <JSExport>
JSExportAs
(transDictToNative  /** handleJavascriptAPIWithDict 作为js方法的别名 */,
 - (void)handleJavascriptAPIWithDict:(NSDictionary *)dict
 );
@end

@interface VPUPWebView : NSObject

@property (nonatomic, readonly) UIView *webView;

@property (nonatomic, weak)     id<VPUPWebViewDelegate> delegate;
@property (nonatomic, strong)   JSContext               *context;

@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSURLCache *cache;

@property (nonatomic, assign, getter=isLandscape) BOOL landscape;

//不拦截url进行本地支付
@property (nonatomic, assign) BOOL disableNativePayment;
@property (nonatomic, assign) BOOL disableDeepLink;


+ (VPUPWebView *)initWebViewWithFrame:(CGRect)frame;

- (void)setUpWebViewWithFrame:(CGRect)frame;

- (void)startLoadingWithUrl:(NSString *)url;
- (void)startLoadingWithHtmlString:(NSString *)htmlString;

- (BOOL)canGoBack;
- (void)goBack;

- (void)stop;
- (void)removeCache;

- (void)setFrame:(CGRect)frame;

- (void)setZoomScale:(double)scale;

- (CGFloat)progress;

@property (nonatomic, weak) NSDictionary<NSString *,VPUPWebViewCallback> *JSCallOCDict;

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback;

@end
