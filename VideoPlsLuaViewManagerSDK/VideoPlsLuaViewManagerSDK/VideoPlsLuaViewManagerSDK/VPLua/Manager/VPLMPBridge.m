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
#import "VPUPLocalStorage.h"
#import "VPLMPRedirectManager.h"
#import "VPLMPOpenAds.h"

@implementation VPLMPBridge

+ (VPLBaseNode *)luaNodeFromLuaState:(lua_State *)l {
    LuaViewCore* lv_luaviewCore = LV_LUASTATE_VIEW(l);
    VPLBaseNode *node = (id)lv_luaviewCore.viewController;
    return node;
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName {
    const struct luaL_Reg staticFunctions [] = {
        {"appletSize", getAppletSize},
        {"showRetryPage", showRetryPage},
        {"showErrorPage", showErrorPage},
        {"canGoBack", canGoBack},
        {"goBack", goBack},
        {"closeView", closeView},
        {"getStorageData", getStorageData},
        {"setStorageData", setStorageData},
        {"openApplet", openApplet},
        {"openAds", openAds},
        {NULL, NULL}
    };
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    luaL_openlib(L, "Applet", staticFunctions, 0);
    return 1;
}

static int getAppletSize(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    lua_pushnumber(L, node.nodeController.rootView.bounds.size.width);
    lua_pushnumber(L, node.nodeController.rootView.bounds.size.height);
    return 2;
}

static int showRetryPage(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
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
    
    if (node.nodeController.mpDelegate && [node.nodeController.mpDelegate respondsToSelector:@selector(showRetryPage:retryData:nodeId:)]) {
        [node.nodeController.mpDelegate showRetryPage:retryMessage retryData:data nodeId:node.nodeId];
    }
    
    return 0;
}

static int showErrorPage(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    NSString *errorMessage = nil;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        errorMessage = lv_paramString(L, 2);
    }
    
    if (node.nodeController.mpDelegate && [node.nodeController.mpDelegate respondsToSelector:@selector(showErrorPage:)]) {
        [node.nodeController.mpDelegate showErrorPage:errorMessage];
    }
    return 0;
}

static int canGoBack(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (node.nodeController.mpDelegate && [node.nodeController.mpDelegate respondsToSelector:@selector(canGoBack)]) {
        BOOL canGoBack = [node.nodeController.mpDelegate canGoBack];
        lua_pushboolean(L, canGoBack);
        return 1;
    }
    return 0;
}

static int goBack(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (node.nodeController.mpDelegate && [node.nodeController.mpDelegate respondsToSelector:@selector(goBack)]) {
        [node.nodeController.mpDelegate goBack];
    }
    return 0;
}

static int closeView(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    
    if (node.nodeController.mpDelegate && [node.nodeController.mpDelegate respondsToSelector:@selector(closeView)]) {
        [node.nodeController.mpDelegate closeView];
    }
    return 0;
}

static int getStorageData(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    NSString *key = nil;
    NSString *file = node.developerUserId;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        key = lv_paramString(L, 2);
    }
    
    if( lua_gettop(L) >= 3 && lua_isstring(L, 3)) {
        file = lv_paramString(L, 3);
    }
    
    NSString *value = [VPUPLocalStorage getStorageDataWithFile:file key:key];
    if (value) {
        lua_pushstring(L, [value UTF8String]);
        return 1;
    }
    
    return 0;
}

static int setStorageData(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    NSString *key = nil;
    NSString *value = nil;
    NSString *file = node.developerUserId;
    if( lua_gettop(L) >= 2 && lua_isstring(L, 2)) {
        key = lv_paramString(L, 2);
        
        if( lua_gettop(L) >= 3 && lua_isstring(L, 3)) {
            value = lv_paramString(L, 3);
        }
        
        if( lua_gettop(L) >= 4 && lua_isstring(L, 4)) {
            file = lv_paramString(L, 4);
        }
        
        [VPUPLocalStorage setStorageDataWithFile:file key:key value:value];
    }
    
    return 0;
}

static int openApplet(lua_State *L) {
    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    
    NSDictionary *dict = nil;
    if( lua_gettop(L) >= 2 && lua_istable(L, 2)) {
        dict = lv_luaTableToDictionary(L, 2);
    }
    
    if (!dict) {
        return 0;
    }
    
    VPLMPRedirectOrientation orientation = node.nodeController.portrait ? VPLMPRedirectOrientationPortrait : VPLMPRedirectOrientationLandscape;
    
    [VPLMPRedirectManager redirectMPWithDictionary:dict currentOrientation:orientation completeBlock:^(BOOL success, NSError *error) {
        
    }];
    return 0;
}

static int openAds(lua_State *L) {
//    VPLBaseNode *node = [VPLMPBridge luaNodeFromLuaState:L];
    
    NSDictionary *dict = nil;
    if( lua_gettop(L) >= 2 && lua_istable(L, 2)) {
        dict = lv_luaTableToDictionary(L, 2);
    }
    
    if (!dict) {
        return 0;
    }
    
    [VPLMPOpenAds openAdsWithParams:dict];
    return 0;
}

@end
