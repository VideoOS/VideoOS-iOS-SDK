//
//  VPLPage.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/4/10.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLPage.h"
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LuaViewCore.h>

NSString *const VPLPageWillAppearNotification = @"VPLPageWillAppearNotification";
NSString *const VPLPageDidAppearNotification = @"VPLPageDidAppearNotification";
NSString *const VPLPageWillDisappearNotification = @"VPLPageWillDisappearNotification";
NSString *const VPLPageDidDisappearNotification = @"VPLPageDidDisappearNotification";

typedef NS_ENUM(int, VPluaPageCallback) {
    kVPluaPageCallbackOnPageWillAppear = 1,
    kVPluaPageCallbackOnPageDidAppear,
    kVPluaPageCallbackOnPageWillDisappear,
    kVPluaPageCallbackOnPageDidDisappear
};

static char *callbackPageKeys[] = { "", "onPageWillAppear", "onPageDidAppear", "onPageWillDisappear", "onPageDidDisappear" };

@interface VPLPage ()

@end

@implementation VPLPage

-(id) init:(lua_State*) l{
    self = [super init];
    if(self) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        [self registerNotification];
    }
    return self;
}

-(void) dealloc{
    [self deregisterNotification];
}

#pragma mark page notification
- (void)pageWillAppear {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPluaPageCallbackOnPageWillAppear];
    });
}

- (void)pageDidAppear {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPluaPageCallbackOnPageDidAppear];
    });
}

- (void)pageWillDisappear {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPluaPageCallbackOnPageWillDisappear];
    });
}

- (void)pageDidDisappear {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPluaPageCallbackOnPageDidDisappear];
    });
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageWillAppear) name:VPLPageWillAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidAppear) name:VPLPageDidAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageWillDisappear) name:VPLPageWillDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidDisappear) name:VPLPageDidDisappearNotification object:nil];
}

- (void)deregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLPageWillAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLPageDidAppearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLPageWillDisappearNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLPageDidDisappearNotification object:nil];
}

- (id)lv_nativeObject {
    return self;
}

- (void)callback:(VPluaPageCallback)idx {
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

static int lvNewPage (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLPage class]];
    {
        VPLPage* page = [[c alloc] init:L];
        
        {
            NEW_USERDATA(userData, NativeObject);
            page.lv_userData = userData;
            userData->object = CFBridgingRetain(page);
            
            luaL_getmetatable(L, META_TABLE_NativeObject);
            lua_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    [LVUtil reg:L clas:self cfunc:lvNewPage globalName:globalName defaultName:@"Page"];
    
    const struct luaL_Reg memberFunctions [] = {
        { "pageCallback", pageCallback },
        { callbackPageKeys[kVPluaPageCallbackOnPageWillAppear], onPageWillAppear },
        { callbackPageKeys[kVPluaPageCallbackOnPageDidAppear], onPageDidAppear },
        { callbackPageKeys[kVPluaPageCallbackOnPageWillDisappear], onPageWillDisappear },
        { callbackPageKeys[kVPluaPageCallbackOnPageDidDisappear], onPageDidDisappear },
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L, META_TABLE_NativeObject);
    luaL_openlib(L, NULL, memberFunctions, 0);
    return 1;
}

static int onPageWillAppear (lua_State *L) {
    return setCallback(L, kVPluaPageCallbackOnPageWillAppear);
}

static int onPageDidAppear (lua_State *L) {
    return setCallback(L, kVPluaPageCallbackOnPageDidAppear);
}

static int onPageWillDisappear (lua_State *L) {
    return setCallback(L, kVPluaPageCallbackOnPageWillDisappear);
}

static int onPageDidDisappear (lua_State *L) {
    return setCallback(L, kVPluaPageCallbackOnPageDidDisappear);
}

static int pageCallback(lua_State *L) {
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
            for (int i = 0; i < sizeof(callbackPageKeys) / sizeof(callbackPageKeys[0]); ++i) {
                if (strcmp(key, callbackPageKeys[i]) == 0) {
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

@end
