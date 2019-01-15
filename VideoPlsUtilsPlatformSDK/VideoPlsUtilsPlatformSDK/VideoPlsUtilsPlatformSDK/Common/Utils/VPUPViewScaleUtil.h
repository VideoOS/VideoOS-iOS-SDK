//
//  VPUPViewScaleUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/11/1.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VPUPViewScale MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) / 375.0f

#define IS_NOT_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 || [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)
#define SYSTEM_FONT_SCALE (IS_NOT_IOS9 ? 1.0f / 1.022f : 1)

#define VPUPFontScale (VPUPViewScale < 0.75 ? 0.75 : VPUPViewScale > 1.5 ? 1.5 : VPUPViewScale) * SYSTEM_FONT_SCALE
