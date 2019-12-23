//
//  VPLNativeScanner.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2017/12/29.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>
@class VPLBaseNode;

@interface VPLNativeScanner : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName;

@property (nonatomic, weak) VPLBaseNode *luaNode;

@end
