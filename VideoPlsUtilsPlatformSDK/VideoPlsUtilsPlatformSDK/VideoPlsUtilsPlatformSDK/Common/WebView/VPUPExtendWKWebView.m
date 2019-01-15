//
//  VPUPExtendWKWebView.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPExtendWKWebView.h"
#import "VPUPServiceManager.h"
#import "VPUPWKWebViewDelegate.h"

@interface VPUPExtendWKWebView ()

@property (nonatomic, assign) BOOL isLandscape;

@end

@implementation VPUPExtendWKWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (void)load {
    
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    return [self initWithFrame:frame configuration:configuration];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        if (@available(iOS 11.0, *)) {
            //竖屏自动兼容
            if(!self.isLandscape) {
                self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            }
            else {
                self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
    }
    return self;
}

- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name {
    [self.configuration.userContentController addScriptMessageHandler:scriptMessageHandler name:name];
}

- (void)removeScriptMessageHandlerForName:(NSString *)name {
    [self.configuration.userContentController removeScriptMessageHandlerForName:name];
}

- (void)setIsLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    if (@available(iOS 11.0, *)) {
        if(!self.isLandscape) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        } else {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
}

- (void)dealloc {
    
}

@end
