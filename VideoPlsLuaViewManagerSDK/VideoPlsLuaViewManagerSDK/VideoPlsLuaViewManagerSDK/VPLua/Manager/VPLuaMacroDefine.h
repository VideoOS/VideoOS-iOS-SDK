//
//  VPLuaMacroDefine.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/5/8.
//  Copyright © 2018 videopls. All rights reserved.
//

#ifndef VPLuaMacroDefine_h
#define VPLuaMacroDefine_h

#define VPUPViewScale MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) / 375.0f

#define IS_NOT_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 || [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)
#define SYSTEM_FONT_SCALE (IS_NOT_IOS9 ? 1.0f / 1.022f : 1)

#define VPUPFontScale (VPUPViewScale < 0.75 ? 0.75 : VPUPViewScale > 1.5 ? 1.5 : VPUPViewScale) * SYSTEM_FONT_SCALE

//10.0以上字体变大1.022倍,9.0以下字体数字会变大
//#define IS_NOT_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 || [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)
//#define FONT_SCALE (IS_NOT_IOS9 ? 1.0f / 1.022f : 1)

#endif /* VPLuaMacroDefine_h */
