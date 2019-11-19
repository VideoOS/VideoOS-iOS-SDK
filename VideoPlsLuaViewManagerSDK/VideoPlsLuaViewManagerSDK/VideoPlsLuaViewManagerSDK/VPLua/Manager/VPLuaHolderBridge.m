//
//  VPLuaHolderBridge.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderBridge.h"
#import <VPLuaViewSDK/LVUtil.h>
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>
#import "VPLuaNodeController.h"
#import "VPLuaBaseNode.h"

@implementation VPLuaHolderBridge

+ (VPLuaBaseNode *)luaNodeFromLuaState:(lua_State *)l {
    LuaViewCore* lv_luaviewCore = LV_LUASTATE_VIEW(l);
    VPLuaBaseNode *luaNode = (id)lv_luaviewCore.viewController;
    return luaNode;
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    const struct luaL_Reg staticFunctions [] = {
        {"holderSize", getHolderSize},
        {"showRetryPage", showRetryPage},
        {"showErrorPage", showErrorPage},
        {NULL, NULL}
    };
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    luaL_openlib(L, "Holder", staticFunctions, 0);
    return 1;
}

static int getHolderSize(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaHolderBridge luaNodeFromLuaState:L];
    lua_pushnumber(L, luaNade.luaController.rootView.bounds.size.width);
    lua_pushnumber(L, luaNade.luaController.rootView.bounds.size.height);
    return 2;
}

static int showRetryPage(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaHolderBridge luaNodeFromLuaState:L];
    NSString *retryMessage = nil;
    id data = nil;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        retryMessage = lv_paramString(L, 2);
    }

    if ( lua_gettop(L) >= 3) {
        if (lua_type(L, 3) == LUA_TTABLE) {
            data = lv_luaTableToDictionary(L, 3);
        }
    }
    
    if (luaNade.luaController.holderDelegate && [luaNade.luaController.holderDelegate respondsToSelector:@selector(showRetryPage:retryData:nodeId:)]) {
        [luaNade.luaController.holderDelegate showRetryPage:retryMessage retryData:data nodeId:luaNade.nodeId];
    }
    
    return 0;
}

static int showErrorPage(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaHolderBridge luaNodeFromLuaState:L];
    NSString *errorMessage = nil;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        errorMessage = lv_paramString(L, 2);
    }
    
    if (luaNade.luaController.holderDelegate && [luaNade.luaController.holderDelegate respondsToSelector:@selector(showErrorPage:)]) {
        [luaNade.luaController.holderDelegate showErrorPage:errorMessage];
    }
    return 0;
}

@end
