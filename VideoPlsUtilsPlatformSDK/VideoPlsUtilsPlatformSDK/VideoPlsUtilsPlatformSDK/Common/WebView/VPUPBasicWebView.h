//
//  VPUPBasicWebView.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Bill on 22/05/2017.
//  Copyright © 2017 videopls.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPUPWKWebViewJSBridge.h"

typedef void(^VPUPWebViewCallback)(id result);
@protocol VPUPBasicWebViewDelegate <NSObject>

@optional
- (void)webViewDidStartLoad;
- (void)loadCompleteWithTitle:(NSString *)title error:(NSError *)error;

@end


@interface VPUPBasicWebView : UIView

@property (nonatomic, weak) id<VPUPBasicWebViewDelegate> delegate;
@property (nonatomic, readonly) NSString *linkUrl;

@property (nonatomic, strong) NSDictionary<NSString *,VPUPWebViewCallback> *JSCallOCDict;

// iOS 11会自适应挤压, 横屏时设置不挤压, 竖屏时设置挤压
@property (nonatomic, assign, getter=isLandscape) BOOL landscape;

@property (nonatomic, assign) BOOL disableNativePayment;


- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url;
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url jsCallOCDictionary:(NSDictionary<NSString *,VPUPWebViewCallback> *)JSCallOCDictionary;

- (void)addJSBridge:(VPUPWKWebViewJSBridge *)jsBridge;

- (void)loadUrl:(NSString *)url;

- (void)setProgressColor:(UIColor *)color;

- (BOOL)canGoBack;
- (void)goBack;

- (void)stop;
- (void)stopAndRemoveBasicWebview;

- (void)nativeCallWebviewWithJS:(NSString *)jsFuncName paramaters:(NSArray *)params callback:(VPUPWebViewCallback)callback;


@end
