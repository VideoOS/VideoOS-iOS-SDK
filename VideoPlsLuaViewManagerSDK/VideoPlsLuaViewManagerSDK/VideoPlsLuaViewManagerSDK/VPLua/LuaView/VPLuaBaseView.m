//
//  VPLuaBaseView.m
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLuaBaseView.h"
#import "VPLuaImageView.h"
#import "VPLuaButton.h"
#import "VPLuaThroughView.h"
#import "VPLuaNativeBridge.h"
#import "VPLuaWebView.h"
#import "VPLuaLoadingView.h"
#import "VPLuaLabel.h"
#import "VPLuaCollectionView.h"
#import "VPLuaRefreshCollectionView.h"
#import "VPLuaGradientView.h"
#import "VPLuaNativeScanner.h"
#import "VPLuaTextField.h"
#import "VPLuaWindow.h"
#import "VPLuaSVGAView.h"
#import "VPLuaMedia.h"
#import "VPLuaMQTT.h"
#import "VPLuaPage.h"
#import "VPLuaPlayer.h"
#import "VPLuaScrollView.h"
#import "VPLuaHttpRequest.h"
#import "VPLuaAppletBridge.h"

@implementation VPLuaBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self[@"Image"] = [VPLuaImageView class];
        self[@"Button"] = [VPLuaButton class];
        self[@"Label"] = [VPLuaLabel class];
        self[@"CollectionView"] = [VPLuaCollectionView class];
        self[@"ThroughView"] = [VPLuaThroughView class];
        self[@"LoadingView"] = [VPLuaLoadingView class];
        self[@"RefreshCollectionView"] = [VPLuaRefreshCollectionView class];
        self[@"TextField"] = [VPLuaTextField class];
        
        [VPLuaWebView lvClassDefine:self.luaviewCore.l globalName:@"WebView"];
        [VPLuaNativeBridge lvClassDefine:self.luaviewCore.l globalName:@"Native"];
        [VPLuaNativeScanner lvClassDefine:self.luaviewCore.l globalName:@"NativeScanner"];
        [VPLuaWindow lvClassDefine:self.luaviewCore.l globalName:@"NativeWindow"];
        [VPLuaSVGAView lvClassDefine:self.luaviewCore.l globalName:@"SVGAView"];
        [VPLuaMedia lvClassDefine:self.luaviewCore.l globalName:@"Media"];
        [VPLuaMQTT lvClassDefine:self.luaviewCore.l globalName:@"Mqtt"];
        [VPLuaPage lvClassDefine:self.luaviewCore.l globalName:@"Page"];
        [VPLuaPlayer lvClassDefine:self.luaviewCore.l globalName:@"MediaPlayer"];
        [VPLuaGradientView lvClassDefine:self.luaviewCore.l globalName:@"GradientView"];
        [VPLuaScrollView lvClassDefine:self.luaviewCore.l globalName:@"ScrollView"];
        [VPLuaHttpRequest lvClassDefine:self.luaviewCore.l globalName:@"HttpRequest"];
        [VPLuaAppletBridge lvClassDefine:self.luaviewCore.l globalName:@"Applet"];
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
