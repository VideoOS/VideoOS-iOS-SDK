//
//  VPLuaAppletWebView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/12.
//  Copyright © 2019 videopls. All rights reserved.
//
#import "VPUPBasicWebView.h"
#import <UIKit/UIKit.h>

@protocol VPLuaAppletWebViewDelegate<NSObject>

- (void)callFromJSMethod:(NSString *)method args:(NSDictionary *)args;

@end

@interface VPLuaAppletWebView : VPUPBasicWebView

@property (nonatomic, weak) id<VPLuaAppletWebViewDelegate> jsAppletDelegate;

@property (nonatomic, strong) NSString *appletId;

@property (nonatomic, strong) NSString *developUserId;


- (NSString *)getJSCallback:(NSDictionary *)params;
- (void)jsCallMethod:(NSString *)callMethod params:(NSArray *)params;

@end
