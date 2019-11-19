//
//  VPHybirdHolderLandscapeContainer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPHybirdHolderLandscapeContainer.h"
#import "VPLuaNodeController.h"
#import "VPUPRoutes.h"
#import "VPUPHexColors.h"
#import "VPUPEncryption.h"
#import "VPLuaLoader.h"
#import "VPUPHexColors.h"
#import "VPUPViewScaleUtil.h"
#import "VPUPPathUtil.h"
#import "VPUPWebView.h"
#import "VPUPWKWebView.h"
#import "VPUPExtendWKWebView.h"
#import "VPUPWKWebViewJSBridge.h"
#import <WebKit/WebKit.h>
#import "VPUPJsonUtil.h"
#import "VPUPCommonInfo.h"
#import "VPUPActionManager.h"
#import "VPLuaSDK.h"
#import "VPUPValidator.h"
#import "VPLuaOSView.h"
#import "VPLuaNativeBridge.h"

@interface VPHybirdHolderLandscapeContainer()<VPUPWebViewDelegate, WKScriptMessageHandler>

@property (nonatomic) VPUPWKWebView *webView;
@property (nonatomic) VPUPWKWebViewJSBridge *holderJSBridge;

@property (nonatomic) NSMutableArray *nodeStack;

//holder
@property (nonatomic, assign) BOOL isHolderRetry;
@property (nonatomic) NSString *tempRetryNodeId;
@property (nonatomic) id tempRetryData;
@property (nonatomic, assign) BOOL isHolderError;

@end

@implementation VPHybirdHolderLandscapeContainer

- (void)initContainView {
    
    self.webView = [[VPUPWKWebView alloc] init];
    self.webView.delegate = self;
    self.webView.landscape = YES;
    [self.webView setUpWebViewWithFrame:self.containFrame];
    [self.webView setDisableNativePayment:YES];
    self.webView.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _holderJSBridge = [VPUPWKWebViewJSBridge bridgeForWebView:self.webView.webView scriptDelegate:self];
    _holderJSBridge.messageName = @"Holder";
    [((VPUPExtendWKWebView *)self.webView.webView) addScriptMessageHandler:_holderJSBridge name:_holderJSBridge.messageName];
//    _webView.navigationDelegate = self;

    
    [self.mainView addSubview:self.webView.webView];
    
}

- (void)updateContainUserInfo {
    if (self.getUserInfoBlock) {
        
    }
}

- (void)loadContainView {
    [self updateNavi];
    [self.webView startLoadingWithUrl:self.holder.h5Url];
    [self closeLoadingView];
}

- (void)loadLua:(NSString *)luaUrl data:(NSDictionary *)data {
    
}

- (void)refreshContainerWithData:(id)data {
    [self closeLoadingView];
    [self closeRetryView];
    [self closeErrorView];
    self.rootData = data;
    [self.webView startLoadingWithHtmlString:@""];
    [self.webView startLoadingWithUrl:self.holder.h5Url];
}

- (void)naviBackButtonTapped {
    if ([self.webView canGoBack]) {
        [self.webView goBack];

        if (self.errorView.hidden == NO) {
            [self closeErrorView];
            //小程序唤起的错误页,需要移除node;lua加载引发的错误页,不需要移除node
            if (_isHolderError) {
                _isHolderError = NO;
//                [_luaController removeLastNode];
            }
        } else {
            if (self.retryView.hidden == NO) {
                //当前页面没有重试就回退了,置空所有参数
                if (_isHolderError) {
                    _isHolderError = NO;
                    _tempRetryNodeId = nil;
                    _tempRetryData = nil;
                }
                [self closeRetryView];
            }
//            [_luaController removeLastNode];
        }
    } else {
        [self.naviBar hideBackButton];
    }
}

- (void)destroyView {
//    [self.luaController releaseLuaView];
    [self.webView removeCache];
    [super destroyView];
}

#pragma mark - handle webView method
- (NSString *)getJSCallback:(NSDictionary *)params {
    if (!VPUP_IsStrictExist([params objectForKey:@"callback"])) {
        return nil;
    }
    
    return [params objectForKey:@"callback"];
}

- (void)jsCallback:(NSString *)callbackMethod params:(NSArray *)params {
    if (!callbackMethod) {
        return;
    }
    
    [_holderJSBridge nativeCallWebviewWithJS:callbackMethod paramaters:params completionHandler:^(id data, NSError *error) {
        
    }];
}

- (void)commonDataWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    [sendParams setObject:[VPUPCommonInfo commonParam] forKey:@"common"];
    NSDictionary *sizeDict = @{@"width": @(ceil(self.containFrame.size.width)), @"height": @(ceil(self.containFrame.size.height))};
    [sendParams setObject:sizeDict forKey:@"size"];
    NSString *secretString = [VPLuaSDK sharedSDK].appSecret;
    [sendParams setObject:secretString forKey:@"secret"];
    
    NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
    
    NSArray *paramArray = nil;
    if (sendParamString) {
        paramArray = [NSArray arrayWithObject:sendParamString];
    }
    
    [self jsCallback:jsCallback params:paramArray];
}

- (void)getInitDataWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    
    NSDictionary *data = [self getInitData];
    NSArray *paramArray = nil;
    if (data) {
        [sendParams setObject:data forKey:@"data"];
        
        NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
        
        if (sendParamString) {
            paramArray = [NSArray arrayWithObject:sendParamString];
        }
    }
    
    [self jsCallback:jsCallback params:paramArray];
}

- (void)showErrorPageWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    
    _isHolderError = YES;
    [self showErrorView];
    if (!VPUP_IsStrictExist([dict objectForKey:@"message"])) {
        [self.errorView useDefaultMessage];
    } else {
        [self.errorView changeErrorMessage:[dict objectForKey:@"message"]];
    }
}

- (void)updateNaviTitleWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    if (VPUP_IsStrictExist([dict objectForKey:@"title"])) {
        [self.naviBar updateNaviTitle:[dict objectForKey:@"title"]];
    }
}

- (void)openHolderWithParameters:(NSDictionary *)params {
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        return;
    }
    if (!VPUP_IsStrictExist([dict objectForKey:@"holderId"]) || ![[dict objectForKey:@"holderId"] isKindOfClass:[NSString class]]) {
        return;
    }
    if (![dict objectForKey:@"screenType"]) {
        return;
    }
    if (![dict objectForKey:@"appType"]) {
        return;
    }
    
    NSString *holderId = [dict objectForKey:@"holderId"];
    NSInteger screenType = [[dict objectForKey:@"screenType"] integerValue];
    if (screenType < 1 || screenType > 2) {
        screenType = 1;
    }
    NSInteger appType = [[dict objectForKey:@"appType"] integerValue];
    if (appType < 1 || appType > 2) {
        appType = 1;
    }
    
    id data = [dict objectForKey:@"data"];
    
    NSString *schemePath = [NSString stringWithFormat:@"holder?holderId=%@&type=%d&appType=%d", holderId, screenType, appType];
    
    [VPUPActionManager pushAction:VPUP_SchemeAddPath(schemePath, @"LuaView") data:data sender:self];
}

- (void)networkEncryptWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        [self jsCallback:jsCallback params:nil];
        return;
    }
    if (!VPUP_IsStrictExist([dict objectForKey:@"data"]) || ![[dict objectForKey:@"data"] isKindOfClass:[NSString class]]) {
        [self jsCallback:jsCallback params:nil];
        return;
    }
    
    NSString *data = [dict objectForKey:@"data"];
    
    NSString *secretString = [VPLuaSDK sharedSDK].appSecret;
    
    NSString *result = [VPUPAESUtil aesEncryptString:data key:secretString initVector:secretString];
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    [sendParams setObject:result forKey:@"encryptData"];
    
    NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
    
    NSArray *paramArray = nil;
    if (sendParamString) {
        paramArray = [NSArray arrayWithObject:sendParamString];
    }
    
    [self jsCallback:jsCallback params:paramArray];
}

- (void)networkDecryptWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    NSDictionary *dict = [params objectForKey:@"msg"];
    if (!dict) {
        [self jsCallback:jsCallback params:nil];
        return;
    }
    if (!VPUP_IsStrictExist([dict objectForKey:@"data"]) || ![[dict objectForKey:@"data"] isKindOfClass:[NSString class]]) {
        [self jsCallback:jsCallback params:nil];
        return;
    }
    
    NSString *data = [dict objectForKey:@"data"];
    
    NSString *secretString = [VPLuaSDK sharedSDK].appSecret;
    
    NSString *result = [VPUPAESUtil aesDecryptString:data key:secretString initVector:secretString];
    
    NSString *base64Result = [VPUPBase64Util base64EncryptionString:result];
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    [sendParams setObject:base64Result forKey:@"decryptData"];
    
    NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
    
    NSArray *paramArray = nil;
    if (sendParamString) {
        paramArray = [NSArray arrayWithObject:sendParamString];
    }
    
    [self jsCallback:jsCallback params:paramArray];
}

- (void)openUrlWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    
    NSDictionary *dict = [params objectForKey:@"msg"];
    
    NSMutableDictionary *sendJSParams = [NSMutableDictionary dictionary];
    [sendJSParams setObject:@(0) forKey:@"canOpen"];
    if (!dict) {
        NSString *sendJSParamString = VPUP_DictionaryToJson(sendJSParams);
        [self jsCallback:jsCallback params:@[sendJSParamString]];
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
        [self jsCallback:jsCallback params:@[sendJSParams]];
        return;
    }
    
    [sendParams setObject:actionString forKey:@"actionString"];
    [sendParams setObject:@(3) forKey:@"eventType"];    //eventTypeClick
    [sendParams setObject:@(1) forKey:@"actionType"];   //actionTypeOpenUrl
    [sendParams setObject:[VPUPMD5Util md5HashString:actionString] forKey:@"adID"];
    [sendParams setObject:self.holder.naviSetting.naviTitle ? self.holder.naviSetting.naviTitle : @"" forKey:@"adName"];
    
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
    [self jsCallback:jsCallback params:@[sendJSParamString]];
}


#pragma mark - delegate
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
    }
    
}

- (void)loadCompleteTitle:(NSString *)title error:(NSError *)error {
    if ([self.webView canGoBack]) {
        [self.naviBar showBackButton];
    } else {
        [self.naviBar hideBackButton];
    }
    [self.naviBar updateNaviTitle:title];
    if (!error) {
        [self closeLoadingView];
    } else {
        NSLog(@"======webview failed error: %@", error);
    }
}

- (void)didStartLoad {
    if ([self.webView canGoBack]) {
        [self.naviBar showBackButton];
    }
}

- (void)getUserInfo {
    
}


//network
- (void)retryNetwork {
    [self showLoadingView];
    if (!_isHolderRetry) {
        [self showLoadingView];
        if (self.retryLuaFiles) {
            self.retryLuaFiles = false;
//            [self loadLuaFiles];
        } else {
            [super retryNetwork];
        }
    } else {
        _isHolderRetry = NO;
        [self closeRetryView];
        if (_tempRetryNodeId) {
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  @(VPLuaHolderActionTypeRetry),@"holderActionType",
//                                  @(VPLuaEventTypeHolderAction), @"eventType",
//                                  _tempRetryData, @"data", nil];
//            [self.luaController callLuaMethod:@"retry" nodeId:_tempRetryNodeId data:dict];
        }
        _tempRetryNodeId = nil;
        _tempRetryData = nil;
    }
    
}

//lua node controller
- (void)showRetryPage:(NSString *)retryMessage retryData:(id)data nodeId:(NSString *)nodeId {
    [self showRetryView];
    if (retryMessage != nil && ![retryMessage isEqualToString:@""]) {
        [self.retryView changeNetworkMessage:retryMessage];
    } else {
        [self.retryView useDefaultMessage];
    }
    _isHolderRetry = YES;
    _tempRetryData = data;
    _tempRetryNodeId = nodeId;
}

- (void)showErrorPage:(NSString *)errorMessage {
    _isHolderError = YES;
    [self showErrorView];
    if (errorMessage != nil && ![errorMessage isEqualToString:@""]) {
        [self.errorView changeErrorMessage:errorMessage];
    } else {
        [self.errorView useDefaultMessage];
    }
}

@end
