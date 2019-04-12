//
//  VPDPNativeBridge.h
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIManager.h"
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

#import "VPLuaBaseNode.h"
#import "VPLuaNetworkManager.h"

@class VPLuaBaseNode;

extern NSString *const VPLuaScreenChangeNotification;
extern NSString *const VPLuaNotifyUserLoginedNotification;
extern NSString *const VPLuaRequireLoginNotification;
extern NSString *const VPLuaActionNotification;

@interface VPLuaNativeBridge : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*)globalName;

+ (VPLuaBaseNode *)luaNodeFromLuaState:(lua_State *)l;

@end
