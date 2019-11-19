//
//  VPHolderContainerNaviSetting.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/27.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPHolderContainerNaviSetting.h"
#import "VPUPHexColors.h"

@implementation VPHolderContainerNaviSetting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navibackgroundColor = [VPUPHXColor vpup_colorWithHexARGBString:@"2E323A"];
        self.naviTitleColor = [VPUPHXColor vpup_colorWithHexARGBString:@"ffffff"];
        self.naviButtonColor = [VPUPHXColor vpup_colorWithHexARGBString:@"ffffff"];
        self.naviAlpha = 1;
    }
    return self;
}

+ (instancetype)initWithDictionary:(NSDictionary *)dict {
    VPHolderContainerNaviSetting *setting = [[VPHolderContainerNaviSetting alloc] init];
    if ([dict objectForKey:@"miniAppName"]) {
        setting.holderName = [dict objectForKey:@"miniAppName"];
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
