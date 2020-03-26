//
//  VPLBaseView.m
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLBaseView.h"
#import "VPLImageView.h"
#import "VPLButton.h"
#import "VPLThroughView.h"
#import "VPLNativeBridge.h"
#import "VPLWebView.h"
#import "VPLLoadingView.h"
#import "VPLLabel.h"
#import "VPLCollectionView.h"
#import "VPLRefreshCollectionView.h"
#import "VPLGradientView.h"
#import "VPLNativeScanner.h"
#import "VPLTextField.h"
#import "VPLWindow.h"
#import "VPLSVGAView.h"
#import "VPLMedia.h"
#import "VPLMQTT.h"
#import "VPLPage.h"
#import "VPLPlayer.h"
#import "VPLScrollView.h"
#import "VPLHttpRequest.h"
#import "VPLMPBridge.h"
#import "VPLNotification.h"
#import "VPLACRCloud.h"

@implementation VPLBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self[@"Image"] = [VPLImageView class];
        self[@"Button"] = [VPLButton class];
        self[@"Label"] = [VPLLabel class];
        self[@"CollectionView"] = [VPLCollectionView class];
        self[@"ThroughView"] = [VPLThroughView class];
        self[@"LoadingView"] = [VPLLoadingView class];
        self[@"RefreshCollectionView"] = [VPLRefreshCollectionView class];
        self[@"TextField"] = [VPLTextField class];
        
        [VPLWebView lvClassDefine:self.luaviewCore.l globalName:@"WebView"];
        [VPLNativeBridge lvClassDefine:self.luaviewCore.l globalName:@"Native"];
        [VPLNativeScanner lvClassDefine:self.luaviewCore.l globalName:@"NativeScanner"];
        [VPLWindow lvClassDefine:self.luaviewCore.l globalName:@"NativeWindow"];
        [VPLSVGAView lvClassDefine:self.luaviewCore.l globalName:@"SVGAView"];
        [VPLMedia lvClassDefine:self.luaviewCore.l globalName:@"Media"];
        [VPLMQTT lvClassDefine:self.luaviewCore.l globalName:@"Mqtt"];
        [VPLPage lvClassDefine:self.luaviewCore.l globalName:@"Page"];
        [VPLPlayer lvClassDefine:self.luaviewCore.l globalName:@"MediaPlayer"];
        [VPLGradientView lvClassDefine:self.luaviewCore.l globalName:@"GradientView"];
        [VPLScrollView lvClassDefine:self.luaviewCore.l globalName:@"ScrollView"];
        [VPLHttpRequest lvClassDefine:self.luaviewCore.l globalName:@"HttpRequest"];
        [VPLMPBridge lvClassDefine:self.luaviewCore.l globalName:@"Applet"];
        [VPLNotification lvClassDefine:self.luaviewCore.l globalName:@"Notification"];
        [VPLACRCloud lvClassDefine:self.luaviewCore.l globalName:@"AcrCloud"];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    
    return hitView;
}

@end
