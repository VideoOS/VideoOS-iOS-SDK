//
//  VPLuaAppletWebView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/12.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletWebView.h"
#import "VPUPExtendWKWebView.h"
#import "VPUPWKWebViewJSBridge.h"
#import "VPUPJsonUtil.h"
#import "VPUPCommonInfo.h"
#import "VPUPValidator.h"
#import "VPUPEncryption.h"
#import <WebKit/WebKit.h>
#import "VPLuaNativeBridge.h"
#import <Foundation/Foundation.h>
#import "VPUPActionManager.h"
#import "VPUPPathUtil.h"
#import "VPLuaSDK.h"
#import "VPUPWKWebView.h"
#import "VPLuaRedirectAppletManager.h"

@interface VPLuaAppletWebView()<VPUPWebViewDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) VPUPWKWebView *webView;
@property (nonatomic) VPUPWKWebViewJSBridge *appletJSBridge;

@end

@implementation VPLuaAppletWebView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWebView];
    }
    return self;
}

- (void)initWebView {
    _webView.delegate = self;
    self.landscape = YES;
    [self setDisableNativePayment:YES];
    
    _appletJSBridge = [VPUPWKWebViewJSBridge bridgeForWebView:nil scriptDelegate:self];
    _appletJSBridge.messageName = @"Applet";
    [self addJSBridge:_appletJSBridge];
}

- (void)setLandscape:(BOOL)isLandscape {
    [super setLandscape:isLandscape];
    //0 横屏，1竖屏
    NSUInteger param = isLandscape ? 0 : 1;
    [self jsCallMethod:@"orientationChange" params:@[@(param)]];
    
}

- (NSString *)getJSCallback:(NSDictionary *)params {
    if (!VPUP_IsStrictExist([params objectForKey:@"callback"])) {
        return nil;
    }
    
    return [params objectForKey:@"callback"];
}

- (void)jsCallMethod:(NSString *)callMethod params:(NSArray *)params {
    if (!callMethod) {
        return;
    }
    
    [_appletJSBridge nativeCallWebviewWithJS:callMethod paramaters:params completionHandler:^(id data, NSError *error) {
        
    }];
}

//webView call method
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSDictionary *data = message.body;
    if (!VPUP_IsStrictExist([data objectForKey:@"method"]) || ![[data objectForKey:@"method"] isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *method = [data objectForKey:@"method"];
    //args转object
    NSDictionary *params = nil;
    if ([data objectForKey:@"args"]) {
        NSString *args = [data objectForKey:@"args"];
        params = VPUP_JsonToDictionary(args);
    }
    
    
    NSString *methodString = [NSString stringWithFormat:@"%@%@", method, @"WithParameters:"];
    
    SEL selector = NSSelectorFromString(methodString);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:params];
    } else {
        if (self.jsAppletDelegate && [self.jsAppletDelegate respondsToSelector:@selector(callFromJSMethod:args:)]) {
            [self.jsAppletDelegate callFromJSMethod:method args:params];
        }
    }
}

- (void)commonDataWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    [sendParams setObject:[VPUPCommonInfo commonParam] forKey:@"common"];
    NSDictionary *sizeDict = @{@"width": @(ceil(self.bounds.size.width)), @"height": @(ceil(self.bounds.size.height))};
    [sendParams setObject:sizeDict forKey:@"size"];
    CGPoint convertPoint = [self convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
    NSDictionary *originDict = @{@"x": @(ceil(convertPoint.x)), @"y": @(ceil(convertPoint.y))};
    [sendParams setObject:originDict forKey:@"origin"];
    NSString *secretString = [VPLuaSDK sharedSDK].appSecret;
    [sendParams setObject:secretString forKey:@"secret"];
    CGFloat scaleSize = [UIScreen mainScreen].scale;
    [sendParams setObject:@(scaleSize) forKey:@"screenScale"];
    NSDictionary *videoInfoDict = [[VPLuaSDK sharedSDK].videoInfo dictionaryValue];
    if (videoInfoDict) {
        [sendParams setObject:videoInfoDict forKey:@"videoInfo"];
    }
    
    
    NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
    
    NSArray *paramArray = nil;
    if (sendParamString) {
        paramArray = [NSArray arrayWithObject:sendParamString];
    }
    
    [self jsCallMethod:jsCallback params:paramArray];
}

- (void)openUrlWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    
    NSDictionary *dict = [params objectForKey:@"msg"];
    
    NSMutableDictionary *sendJSParams = [NSMutableDictionary dictionary];
    [sendJSParams setObject:@(0) forKey:@"canOpen"];
    if (!dict) {
        NSString *sendJSParamString = VPUP_DictionaryToJson(sendJSParams);
        [self jsCallMethod:jsCallback params:@[sendJSParamString]];
        return;
    }
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    
    NSString *actionString = nil;
    NSString *linkUrl = nil;
    NSString *deepLink = nil;
    NSString *selfLink = nil;
    if (VPUP_IsStrictExist([dict objectForKey:@"linkUrl"]) && [[dict objectForKey:@"linkUrl"] isKindOfClass:[NSString class]]) {
        linkUrl = [dict objectForKey:@"linkUrl"];
        [sendParams setObject:linkUrl forKey:@"linkUrl"];
    }
    if (VPUP_IsStrictExist([dict objectForKey:@"deepLink"]) && [[dict objectForKey:@"deepLink"] isKindOfClass:[NSString class]]) {
        deepLink = [dict objectForKey:@"deepLink"];
        [sendParams setObject:deepLink forKey:@"deepLink"];
    }
    if (VPUP_IsStrictExist([dict objectForKey:@"selfLink"]) && [[dict objectForKey:@"selfLink"] isKindOfClass:[NSString class]]) {
        selfLink = [dict objectForKey:@"selfLink"];
        [sendParams setObject:selfLink forKey:@"selfLink"];
    }
    
    if (linkUrl != nil) {
        actionString = linkUrl;
    } else if (deepLink != nil) {
        actionString = deepLink;
    } else if (selfLink != nil) {
        actionString = selfLink;
    }
    
    if (!actionString) {
        [self jsCallMethod:jsCallback params:@[sendJSParams]];
        return;
    }
    
    [sendParams setObject:actionString forKey:@"actionString"];
    [sendParams setObject:@(3) forKey:@"eventType"];    //eventTypeClick
    [sendParams setObject:@(1) forKey:@"actionType"];   //actionTypeOpenUrl
    [sendParams setObject:[VPUPMD5Util md5HashString:actionString] forKey:@"adID"];
    [sendParams setObject:((WKWebView *)self.webView).title ? ((WKWebView *)self.webView).title : @"" forKey:@"adName"];
    
    if (deepLink) {
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:deepLink]];
        if (canOpen) {
            [sendJSParams setObject:@(1) forKey:@"canOpen"];
        } else {
            [sendJSParams setObject:@(2) forKey:@"canOpen"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaActionNotification object:nil userInfo:sendParams];
    
    NSString *sendJSParamString = VPUP_DictionaryToJson(sendJSParams);
    [self jsCallMethod:jsCallback params:@[sendJSParamString]];
}

- (void)openAppletWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    
    VPLuaRedirectOrientation orientation = self.landscape ? VPLuaRedirectOrientationLandscape : VPLuaRedirectOrientationPortrait;
    
    [VPLuaRedirectAppletManager redirectAppletWithDictionary:dict currentOrientation:orientation completeBlock:^(BOOL success, NSError *error) {
        
    }];
}

- (void)setConfigWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    
    if ([dict objectForKey:@"payDisabled"]) {
        BOOL payDisabled = [[dict objectForKey:@"payDisabled"] boolValue];
        self.disableNativePayment = payDisabled;
    }
}

- (void)setStorageDataWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    
    if (![dict objectForKey:@"key"]) {
        return;
    }
    
    NSString *key = [dict objectForKey:@"key"];
    NSString *value = [dict objectForKey:@"value"];
    
    NSString *filePath = [VPUPPathUtil localStoragePath];
    NSString *fileNamePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", self.developUserId, @".plist"]];
    
//    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileNamePath];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileNamePath];
    if (!dataDict) {
        dataDict = [NSMutableDictionary dictionary];
    }
    
    if (value != nil) {
        [dataDict setValue:value forKey:key];
    } else {
        //value == nil, remove key
        if ([dataDict objectForKey:key]) {
            [dataDict removeObjectForKey:key];
        }
    }
    
    [dataDict writeToFile:fileNamePath atomically:YES];
}

- (void)getStorageDataWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        [self jsCallMethod:jsCallback params:nil];
        return;
    }
    
    NSString *filePath = [VPUPPathUtil localStoragePath];
    NSString *fileNamePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", self.developUserId, @".plist"]];
        
//    NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileNamePath];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileNamePath];
    
    if (!dataDict) {
        [self jsCallMethod:jsCallback params:nil];
        return;
    }
    
    NSString *key = nil;
    if ([dict objectForKey:@"key"]) {
        key = [dict objectForKey:@"key"];
    }
    
    NSArray *paramArray = nil;
    
    if (key == nil) {
        NSString *sendParamString = VPUP_DictionaryToJson(dataDict);
        
        if (sendParamString) {
            paramArray = [NSArray arrayWithObject:sendParamString];
        }
    } else {
        if ([dataDict objectForKey:key]) {
            NSString *sendParamString = [dataDict objectForKey:key];
            
            if (sendParamString) {
                paramArray = [NSArray arrayWithObject:sendParamString];
            }
        }
    }
    
    [self jsCallMethod:jsCallback params:paramArray];
}


@end
