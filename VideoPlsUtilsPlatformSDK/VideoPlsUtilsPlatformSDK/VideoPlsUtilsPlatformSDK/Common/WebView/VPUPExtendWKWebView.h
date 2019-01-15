//
//  VPUPExtendWKWebView.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "VPUPWKWebViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VPUPWKWebViewDelegate;

@interface VPUPExtendWKWebView : WKWebView <VPUPWKWebViewDelegate>

@end

NS_ASSUME_NONNULL_END
