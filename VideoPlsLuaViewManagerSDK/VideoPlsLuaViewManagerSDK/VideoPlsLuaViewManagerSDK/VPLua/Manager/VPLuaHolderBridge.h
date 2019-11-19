//
//  VPLuaHolderBridge.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

#import "VPLuaBaseNode.h"
#import "VPLuaNetworkManager.h"

extern NSString *const VPLuaScreenChangeNotification;
extern NSString *const VPLuaNotifyUserLoginedNotification;
extern NSString *const VPLuaRequireLoginNotification;
extern NSString *const VPLuaActionNotification;

@interface VPLuaHolderBridge : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*)globalName;

+ (VPLuaBaseNode *)luaNodeFromLuaState:(lua_State *)l;

@end

