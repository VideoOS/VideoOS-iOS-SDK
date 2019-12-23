//
//  VPLWindow.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2018/1/30.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

@class VPLBaseNode;

@interface VPLWindow : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLBaseNode *luaNode;

@end
