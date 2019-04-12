//
//  VPLuaMQTT.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 08/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaMQTT.h"
#import "LVHeads.h"
#import "LuaViewCore.h"
#import "VPUPMQTTHeader.h"
#import "VideoPlsUtilsPlatformSDK.h"
#import "VPUPMessageTransferStation.h"
#import "VPLuaServiceManager.h"

NSString *const VPLuaMQTTClientMessageNotification = @"VPLuaMQTTClientMessageNotification";

typedef NS_ENUM(int, VPluaMQTTCallback) {
    kVPluaMQTTCallbackOnMeaasge = 1,
};

static char *callbackMQTTKeys[] = { "", "onMessage" };

@interface VPLuaMQTT () <VPUPMQTTObserverProtocol>

@property (nonatomic, copy) NSString *callBackMethod;

@end

@implementation VPLuaMQTT

-(id) init:(lua_State*) l{
    self = [super init];
    if(self) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
    }
    return self;
}

-(void) dealloc{
//    NSLog(@"VPLuaMQTT dealloc");
}

- (id)lv_nativeObject {
    return self;
}

#pragma mark -  MQTT DELEGATE MQTT监听代理事件
- (void)onMessage:(id)dictionary {
    dispatch_async(dispatch_get_main_queue(), ^{
        lua_State* l = self.lv_luaviewCore.l;
        if (l && self.lv_userData&&self.callBackMethod) {
            lua_checkstack32(l);
            lv_pushNativeObject(l, dictionary);
            [LVUtil call:l lightUserData:self.callBackMethod key1:"callback" key2:NULL nargs:1];
        }
    });
}

- (void)callback:(VPluaMQTTCallback)idx message:(NSDictionary *)message {
    lua_State* l = self.lv_luaviewCore.l;
    if (l && self.lv_userData) {
        int stackIndex = lua_gettop(l);
        lua_checkstack32(l);
        
        lv_pushNativeObject(l, message);
        lv_pushUserdata(l, self.lv_userData);
        lv_pushUDataRef(l, idx);
        lv_runFunctionWithArgs(l,1,0);
        
        if (lua_gettop(l) > stackIndex) {
            lua_settop(l, stackIndex);
        }
    }
}

static int lvNewMQTT (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaMQTT class]];
    {
        VPLuaMQTT* mqtt = [[c alloc] init:L];
        
        {
            NEW_USERDATA(userData, NativeObject);
            mqtt.lv_userData = userData;
            userData->object = CFBridgingRetain(mqtt);
            
            luaL_getmetatable(L, META_TABLE_NativeObject);
            lua_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    [LVUtil reg:L clas:self cfunc:lvNewMQTT globalName:globalName defaultName:@"Mqtt"];
    
    const struct luaL_Reg memberFunctions [] = {
        { "mqttCallback", mqttCallback },
        { callbackMQTTKeys[kVPluaMQTTCallbackOnMeaasge], onMessage },
        { "startMqtt", startMqtt },
        { "stopMqtt", stopMqtt },
        { "destroyMqtt", destroyMqtt },
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L, META_TABLE_NativeObject);
    luaL_openlib(L, NULL, memberFunctions, 0);
    return 1;
}

static int onMessage (lua_State *L) {
    return setCallback(L, kVPluaMQTTCallbackOnMeaasge);
}

static int mqttCallback(lua_State *L) {
    LVUserDataInfo *data = (LVUserDataInfo *)lua_touserdata(L, 1);
    if (LVIsType(data, NativeObject) && lua_type(L, 2) == LUA_TFUNCTION) {
        VPLuaMQTT* luaMQTT = (__bridge VPLuaMQTT *)(data->object);
        if(luaMQTT) {
            if (luaMQTT.callBackMethod) {
                [LVUtil unregistry:L key:luaMQTT.callBackMethod];
            }
            luaMQTT.callBackMethod = [VPUPRandomUtil randomStringByLength:3];
            [LVUtil registryValue:L key:luaMQTT.callBackMethod stack:2];
        }
    }
    return 0;
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

static int startMqtt(lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ) {
        VPLuaMQTT* luaMQTT = (__bridge VPLuaMQTT *)(user->object);
        if(luaMQTT) {
            //2: MQTT topic qoc
            if( lua_gettop(L) >= 3) {
                if (lua_type(L, 3) == LUA_TTABLE) {
                    NSDictionary *mqttConfig = lv_luaValueToNativeObject(L, 3);
                    [[NSUserDefaults standardUserDefaults] setObject:mqttConfig forKey:@"mqttConfig"];
                }
                
                if (lua_type(L, 2) == LUA_TTABLE) {
                    [[VPLuaServiceManager sharedManager].messageTransferStation attachWithObserver:luaMQTT];
                    NSDictionary *topics = lv_luaValueToNativeObject(L, 2);
                    if([topics isKindOfClass:[NSDictionary class]]) {
                        [topics enumerateKeysAndObjectsUsingBlock:^(NSString *topic, NSNumber *qos, BOOL * _Nonnull stop) {
                            [[VPLuaServiceManager sharedManager].messageTransferStation addTopic:topic observer:luaMQTT];
                        }];
                    }
                }
            }
        }
    }
    return 0;
}

static int stopMqtt(lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ) {
        VPLuaMQTT* luaMQTT = (__bridge VPLuaMQTT *)(user->object);
        if(luaMQTT) {
            [[VPLuaServiceManager sharedManager].messageTransferStation detachWithObserver:luaMQTT];
        }
    }
    return 0;
}

static int destroyMqtt(lua_State *L) {
    return 0;
}

@end
