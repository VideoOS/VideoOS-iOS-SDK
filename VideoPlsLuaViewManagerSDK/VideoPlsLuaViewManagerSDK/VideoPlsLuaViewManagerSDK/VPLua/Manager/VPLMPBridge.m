//
//  VPLMPBridge.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPBridge.h"
#import <VPLuaViewSDK/LVUtil.h>
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>
#import "VPLNodeController.h"
#import "VPLBaseNode.h"

@implementation VPLMPBridge

+ (VPLBaseNode *)luaNodeFromLuaState:(lua_State *)l {
    LuaViewCore* lv_luaviewCore = LV_LUASTATE_VIEW(l);
    VPLBaseNode *luaNode = (id)lv_luaviewCore.viewController;
    return luaNode;
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    const struct luaL_Reg staticFunctions [] = {
        {"appletSize", getAppletSize},
        {"showRetryPage", showRetryPage},
        {"showErrorPage", showErrorPage},
        {"canGoBack", canGoBack},
        {"goBack", goBack},
        {"closeView", closeView},
        {NULL, NULL}
    };
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    luaL_openlib(L, "Applet", staticFunctions, 0);
    return 1;
}

static int getAppletSize(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
    lua_pushnumber(L, luaNade.nodeController.rootView.bounds.size.width);
    lua_pushnumber(L, luaNade.nodeController.rootView.bounds.size.height);
    return 2;
}

static int showRetryPage(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
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
    
    if (luaNade.nodeController.mpDelegate && [luaNade.nodeController.mpDelegate respondsToSelector:@selector(showRetryPage:retryData:nodeId:)]) {
        [luaNade.nodeController.mpDelegate showRetryPage:retryMessage retryData:data nodeId:luaNade.nodeId];
    }
    
    return 0;
}

static int showErrorPage(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
    NSString *errorMessage = nil;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        errorMessage = lv_paramString(L, 2);
    }
    
    if (luaNade.nodeController.mpDelegate && [luaNade.nodeController.mpDelegate respondsToSelector:@selector(showErrorPage:)]) {
        [luaNade.nodeController.mpDelegate showErrorPage:errorMessage];
    }
    return 0;
}

static int canGoBack(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (luaNade.nodeController.mpDelegate && [luaNade.nodeController.mpDelegate respondsToSelector:@selector(canGoBack)]) {
        BOOL canGoBack = [luaNade.nodeController.mpDelegate canGoBack];
        lua_pushboolean(L, canGoBack);
        return 1;
    }
    return 0;
}

static int goBack(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (luaNade.nodeController.mpDelegate && [luaNade.nodeController.mpDelegate respondsToSelector:@selector(goBack)]) {
        [luaNade.nodeController.mpDelegate goBack];
    }
    return 0;
}

static int closeView(lua_State *L) {
    VPLBaseNode *luaNade = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (luaNade.nodeController.mpDelegate && [luaNade.nodeController.mpDelegate respondsToSelector:@selector(closeView)]) {
        [luaNade.nodeController.mpDelegate closeView];
    }
    return 0;
}

@end
