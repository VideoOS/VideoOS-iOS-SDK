//
//  VPMPContainerNaviSetting.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPMPContainerNaviSetting.h"
#import "VPUPHexColors.h"

@implementation VPMPContainerNaviSetting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navibackgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"2E323A"];
        self.naviTitleColor = [VPUPHXColor vpup_colorWithHexARGBString:@"ffffff"];
        self.naviButtonColor = [VPUPHXColor vpup_colorWithHexARGBString:@"ffffff"];
        self.naviAlpha = 1;
        self.naviShow = YES;
    }
    return self;
}

+ (instancetype)initWithDictionary:(NSDictionary *)dict {
    VPMPContainerNaviSetting *setting = [[VPMPContainerNaviSetting alloc] init];
    if ([dict objectForKey:@"miniAppName"]) {
        setting.name = [dict objectForKey:@"miniAppName"];
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
    
    if ([dict objectForKey:@"navShow"]) {
        BOOL naviShow = [[dict objectForKey:@"navShow"] boolValue];
        setting.naviShow = naviShow;
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
