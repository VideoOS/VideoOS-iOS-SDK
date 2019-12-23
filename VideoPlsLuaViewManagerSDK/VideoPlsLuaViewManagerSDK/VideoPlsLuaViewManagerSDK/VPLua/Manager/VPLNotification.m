//
//  VPLNotification.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/8/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLNotification.h"
#import "VPLBaseNode.h"
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVUtil.h>
#import "VPUPNotificationCenter.h"
#import "VPLConstant.h"
#import "VPUPMD5Util.h"
#import "VPUPRandomUtil.h"

@interface VPLNotification()

@property (nonatomic, assign) BOOL isRegisterNotification;
@property (nonatomic, strong) NSMutableDictionary *registerNotificationDict;

@end

@implementation VPLNotification

-(id) init:(lua_State *)l {
    self = [super init];
    if ( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.luaNode = (id)self.lv_luaviewCore.viewController;
    }
    return self;
}

-(id) lv_nativeObject{
    return self;
}

- (NSMutableDictionary *)registerNotificationDict {
    if (!_registerNotificationDict) {
        _registerNotificationDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _registerNotificationDict;
}

- (void)receiveNotification:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    for (NSString *key in self.registerNotificationDict.allKeys) {
        for (NSString *userInfokey in userInfo.allKeys) {
            if ([key isEqualToString:userInfokey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    lua_State* l = self.lv_luaviewCore.l;
                    if( l ){
                        lua_checkstack32(l);
                        if ([[userInfo objectForKey:userInfokey] isKindOfClass:[NSNull class]]) {
                            [LVUtil call:l lightUserData:[self.registerNotificationDict objectForKey:key] key1:"callback" key2:NULL nargs:0];
                        }
                        else {
                            lv_pushNativeObject(l, [userInfo objectForKey:userInfokey]);
                            [LVUtil call:l lightUserData:[self.registerNotificationDict objectForKey:key] key1:"callback" key2:NULL nargs:1];
                        }
                    }
                });
            }
        }
    }
}

- (void)dealloc {
    
}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewNotification globalName:globalName defaultName:@"Notification"];
    
    const struct luaL_Reg staticFunctions [] = {
        { "postNotification", postNotification },
        { "registerNotification", registerNotification },
        { "removeNotification", removeNotification },
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    
    luaL_openlib(L, NULL, staticFunctions, 0);
    
    return 1;
}

static int lvNewNotification(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLNotification class]];
    {
        VPLNotification* notification = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, NativeObject);
            userData->object = CFBridgingRetain(notification);
            notification.lv_userData = userData;
            
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

static int postNotification(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLNotification* notification = (__bridge VPLNotification *)(user->object);
        if( [notification isKindOfClass:[VPLNotification class]] ){
            if(lua_gettop(L) >= 2) {
                
                NSString *key = nil;
                id data = nil;
                
                if(lua_isstring(L, 2)) {
                    key = lv_paramString(L, 2);
                }
                
                if (!key) {
                    return 0;
                }
                
                if (lua_gettop(L) >= 3) {
                    if( lua_type(L, 3) == LUA_TTABLE ) {// 数据
                        data = lv_luaTableToDictionary(L, 3);
                    }
                }
                
                
                if (!data) {
                    data = [NSNull null];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VPLLuaDataNotification object:nil userInfo:@{key : data}];
                
            }
        }
    }
    return 0;
}

static int registerNotification(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLNotification* notification = (__bridge VPLNotification *)(user->object);
        if( [notification isKindOfClass:[VPLNotification class]] ){
            if(lua_gettop(L) >= 3) {
                
                NSString *key = nil;
                
                if(lua_isstring(L, 2)) {
                    key = lv_paramString(L, 2);
                }
                
                if (!key) {
                    return 0;
                }
                
                NSString *bKeyMethod = [[VPUPMD5Util md5_16bitHashString:key] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
                if( lua_type(L, 3) == LUA_TFUNCTION ) {
                    [LVUtil registryValue:L key:bKeyMethod stack:3];
                }
                
                [notification.registerNotificationDict setObject:bKeyMethod forKey:key];
                
                if (!notification.isRegisterNotification) {
                    notification.isRegisterNotification = YES;
                    [[NSNotificationCenter defaultCenter] addObserver:notification selector:@selector(receiveNotification:) name:VPLLuaDataNotification object:nil];
                }
                
            }
        }
    }
    return 0;
}

static int removeNotification(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLNotification* notification = (__bridge VPLNotification *)(user->object);
        if( [notification isKindOfClass:[VPLNotification class]] ){
            if(lua_gettop(L) >= 2) {
                
                NSString *key = nil;
                
                if(lua_isstring(L, 2)) {
                    key = lv_paramString(L, 2);
                }
                
                if (!key) {
                    return 0;
                }
                
                [notification.registerNotificationDict setObject:nil forKey:key];
                if (!(notification.registerNotificationDict.allKeys.count > 0)) {
                    notification.isRegisterNotification = NO;
                    [[NSNotificationCenter defaultCenter] removeObserver:notification];
                }
            }
        }
    }
    return 0;
}

@end
