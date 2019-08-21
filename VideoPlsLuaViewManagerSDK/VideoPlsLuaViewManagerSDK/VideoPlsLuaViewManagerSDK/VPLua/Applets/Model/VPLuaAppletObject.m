//
//  VPLuaAppletObject.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletObject.h"
#import "VPUPHexColors.h"

@interface VPLuaAppletObject()

@end

@implementation VPLuaAppletObject

+ (instancetype)initWithResponseDictionary:(NSDictionary *)dict {
    VPLuaAppletObject *applet = [[VPLuaAppletObject alloc] init];
    if ([dict objectForKey:@"luaList"]) {
        applet.luaList = [dict objectForKey:@"luaList"];
    }
    if ([dict objectForKey:@"template"]) {
        applet.templateLua = [dict objectForKey:@"template"];
    }
    if ([dict objectForKey:@"attachInfo"]) {
        applet.attachInfo = [dict objectForKey:@"attachInfo"];
    }
    if ([dict objectForKey:@"display"]) {
        applet.naviSetting = [VPLuaAppletContainerNaviSetting initWithDictionary:[dict objectForKey:@"display"]];
    }
    
    return applet;
}

@end

@implementation VPLuaAppletContainerNaviSetting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navibackgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"40505a"];
        self.naviTitleColor = [VPUPHXColor vpup_colorWithHexARGBString:@"ffffff"];
        self.naviButtonColor = [VPUPHXColor vpup_colorWithHexARGBString:@"40505a"];
        self.naviAlpha = 0.9;
    }
    return self;
}

+ (instancetype)initWithDictionary:(NSDictionary *)dict {
    VPLuaAppletContainerNaviSetting *setting = [[VPLuaAppletContainerNaviSetting alloc] init];
    if ([dict objectForKey:@"miniAppName"]) {
        setting.appletName = [dict objectForKey:@"miniAppName"];
    }
    
    if ([dict objectForKey:@"navTitle"]) {
        setting.naviTitle = [dict objectForKey:@"navTitle"];
    }
    
    UIColor *naviBackColor = [self colorWithDictionary:dict key:@"navPaddingColor"];
    if (naviBackColor) {
        setting.navibackgroundColor = naviBackColor;
    }
    
    UIColor *naviTitleColor = [self colorWithDictionary:dict key:@"navColor"];
    if (naviBackColor) {
        setting.naviTitleColor = naviTitleColor;
    }
    
    UIColor *naviButtonColor = [self colorWithDictionary:dict key:@"btnColor"];
    if (naviBackColor) {
        setting.naviButtonColor = naviButtonColor;
    }
    
    if ([dict objectForKey:@"navTransparency"]) {
        CGFloat alpha = [[dict objectForKey:@"navTransparency"] floatValue];
        if (alpha < 0) {
            alpha = 0;
        }
        if (alpha > 1) {
            alpha = 1;
        }
        setting.naviAlpha = alpha;
    }
    return setting;
}

+ (UIColor *)colorWithDictionary:(NSDictionary *)dict key:(NSString *)key {
    if ([dict objectForKey:key]) {
        NSString *colorString = [dict objectForKey:key];
        UIColor *color = [VPUPHXColor vpup_colorWithHexARGBString:colorString];
        if (color) {
            return color;
        }
    }
    return nil;
}

@end
