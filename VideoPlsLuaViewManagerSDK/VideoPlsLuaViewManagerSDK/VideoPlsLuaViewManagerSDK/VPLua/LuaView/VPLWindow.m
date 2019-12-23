//
//  VPLWindow.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096 on 2018/1/30.
//  Copyright © 2018年 videopls. All rights reserved.
//

#import "VPLWindow.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VPLBaseNode.h"
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>

typedef NS_ENUM(NSInteger, VPLWindowCallback) {
    kVPLWindowCallbackOnShow = 1,
    kVPLWindowCallbackOnHide
};

static char *callbackWindowKeys[] = { "", "onShow", "onHide" };

@implementation VPLWindow

-(id) init:(lua_State *)l {
    self = [super init];
    if ( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.luaNode = (id)self.lv_luaviewCore.viewController;
        [self registerNotification];
    }
    return self;
}

#pragma mark application notification
- (void)applicationDidBecomeActive {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLWindowCallbackOnShow];
    });
}

- (void)applicationWillResignActive {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLWindowCallbackOnHide];
    });
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)deregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    [self deregisterNotification];
}

- (void)callback:(VPLWindowCallback)idx {
    lua_State* l = self.lv_luaviewCore.l;
    if (l && self.lv_userData) {
        int stackIndex = lua_gettop(l);
        
        lv_pushUserdata(l, self.lv_userData);
        lv_pushUDataRef(l, idx);
        lv_runFunction(l);
        
        if (lua_gettop(l) > stackIndex) {
            lua_settop(l, stackIndex);
        }
    }
}

static int vplv_setCallbackByKey(lua_State *L, const char* key) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        if ( lua_gettop(L)>=2 ) {
//            VPLWindow* window = (__bridge VPLWindow *)(user->object);
            
            lua_checkstack(L, 8);
            lua_pushvalue(L, 1);
            lv_pushUDataRef(L, USERDATA_KEY_DELEGATE);
            if( lua_type(L, -1)==LUA_TNIL ) {
                lua_settop(L, 2);
                lua_pushvalue(L, 1);
                lua_createtable(L, 0, 0);
                lv_udataRef(L, USERDATA_KEY_DELEGATE );
                
                lua_settop(L, 2);
                lua_pushvalue(L, 1);
                lv_pushUDataRef(L, USERDATA_KEY_DELEGATE);
            }
            lua_pushvalue(L, 2);
            if( key==NULL && lua_type(L, -1) == LUA_TTABLE ) {
                // 如果是表格 设置每个Key
                lua_pushnil(L);
                while (lua_next(L, -2))
                {
                    NSString* key   = lv_paramString(L, -2);
                    lua_setfield(L, -4, key.UTF8String);
                }
            }
            return 0;
        } else {
            lv_pushUDataRef(L, USERDATA_KEY_DELEGATE);
            if ( key ) {
                if ( lua_type(L, -1)==LUA_TTABLE ) {
                    lua_getfield(L, -1, key);
                } else {
                    lua_pushnil(L);
                }
            }
            return 1;
        }
    }
    return 0;
}

static int onShow (lua_State *L) {
    return setCallback(L, kVPLWindowCallbackOnShow);
}

static int onHide (lua_State *L) {
    return setCallback(L, kVPLWindowCallbackOnHide);
}

static int setCallback(lua_State *L, int idx) {
    
    LVUserDataInfo *data = (LVUserDataInfo *)lua_touserdata(L, 1);
    
    if (LVIsType(data, NativeObject)) {
        lua_pushvalue(L, 1);
        if (lua_type(L, 2) == LUA_TFUNCTION) {
            lua_pushvalue(L, 2);
        } else {
            lua_pushnil(L);
        }
        
        lv_udataRef(L, idx);
    }
    
    lv_pushUserdata(L, data);
    
    return 1;
}
//static int callback (lua_State *L) {
//    if ( lua_gettop(L) >= 1 && lua_type(L, 1) == LUA_TTABLE ) {
//
//    }
//    return vplv_setCallbackByKey(L, nil);
//}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewWindow globalName:globalName defaultName:@"NativeWindow"];
    
    const struct luaL_Reg staticFunctions [] = {
        
        {"callback", windowCallback},
        { callbackWindowKeys[kVPLWindowCallbackOnShow], onShow },
        { callbackWindowKeys[kVPLWindowCallbackOnHide], onHide },
        
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    
    luaL_openlib(L, NULL, staticFunctions, 0);
    
    return 1;
}

static int lvNewWindow(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLWindow class]];
    {
        VPLWindow* window = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, NativeObject);
            userData->object = CFBridgingRetain(window);
            window.lv_userData = userData;
            
            luaL_getmetatable(L, META_TABLE_NativeObject );
            lua_setmetatable(L, -2);
            
            if ( lua_gettop(L) >= 1 && lua_type(L, 1) == LUA_TTABLE ) {
                lua_pushvalue(L, 1);
                lv_udataRef(L, USERDATA_KEY_DELEGATE );
            }
        }
    }
    return 1; /* new userdatum is already on the stack */
}

- (void)removeFromSuperview {
    
}

static int windowCallback(lua_State *L) {
    LVUserDataInfo *data = (LVUserDataInfo *)lua_touserdata(L, 1);
    if (LVIsType(data, NativeObject) && lua_type(L, 2) == LUA_TTABLE) {
        lua_pushvalue(L, 2);
        lua_pushnil(L);
        
        while (lua_next(L, -2)) {
            if (lua_type(L, -2) != LUA_TSTRING) {
                continue;
            }
            const char* key = lua_tostring(L, -2);
            int idx = 0;
            for (int i = 0; i < sizeof(callbackWindowKeys) / sizeof(callbackWindowKeys[0]); ++i) {
                if (strcmp(key, callbackWindowKeys[i]) == 0) {
                    idx = i;
                    break;
                }
            }
            
            if (idx != 0) {
                lua_pushvalue(L, 1);
                if (lua_type(L, -2) == LUA_TFUNCTION) {
                    lua_pushvalue(L, -2);
                } else {
                    lua_pushnil(L);
                }
                lv_udataRef(L, idx);
                lua_pop(L, 2);
            } else {
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1);
    }
    
    lv_pushUserdata(L, data);
    
    return 1;
}

@end
