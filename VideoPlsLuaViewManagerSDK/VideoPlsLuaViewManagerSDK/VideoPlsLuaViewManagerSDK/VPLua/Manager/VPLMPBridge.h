//
//  VPLMPBridge.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LVNativeObjBox.h>

#import "VPLBaseNode.h"
#import "VPLNetworkManager.h"

extern NSString *const VPLScreenChangeNotification;
extern NSString *const VPLNotifyUserLoginedNotification;
extern NSString *const VPLRequireLoginNotification;
extern NSString *const VPLActionNotification;

@interface VPLMPBridge : LVNativeObjBox

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*)globalName;

+ (VPLBaseNode *)luaNodeFromLuaState:(lua_State *)l;

@end

