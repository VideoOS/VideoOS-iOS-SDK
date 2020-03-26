//
//  VPLACRCloud.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by videopls on 2020/2/26.
//  Copyright © 2020 videopls. All rights reserved.
//

#import "VPLACRCloud.h"
#import <VPLuaViewSDK/LVHeads.h>
#import <VPLuaViewSDK/LuaViewCore.h>
#import "VideoPlsUtilsPlatformSDK.h"
#import "VPUPServiceManager.h"
#import "VPUPACRCloudAPIManager.h"

@interface VPLACRCloud ()

@property (nonatomic, copy) NSString *callBackMethod;

@end

@implementation VPLACRCloud

- (id)init:(lua_State*) l{
    self = [super init];
    if(self) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
    }
    return self;
}

- (void)dealloc{
//    NSLog(@"VPLACRCloud dealloc");
}

- (id)lv_nativeObject {
    return self;
}

static int lvNewACRCloud (lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLACRCloud class]];
    {
        VPLACRCloud* acr = [[c alloc] init:L];
        
        {
            NEW_USERDATA(userData, NativeObject);
            acr.lv_userData = userData;
            userData->object = CFBridgingRetain(acr);
            
            luaL_getmetatable(L, META_TABLE_NativeObject);
            lua_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int acrRecognizeCallback(lua_State *L){
    LVUserDataInfo *data = (LVUserDataInfo *)lua_touserdata(L, 1);
    if (LVIsType(data, NativeObject) && lua_type(L, 2) == LUA_TFUNCTION) {
        VPLACRCloud* acrCloud = (__bridge VPLACRCloud *)(data->object);
        if(acrCloud) {
            if (acrCloud.callBackMethod) {
                [LVUtil unregistry:L key:acrCloud.callBackMethod];
            }
            acrCloud.callBackMethod = [@"acrRecognizeCallback" stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
            [LVUtil registryValue:L key:acrCloud.callBackMethod stack:2];
        }
    }
    return 0;
}

//if (lua_gettop(L) >= 2 && lua_isfunction(L, 2)) {
//    __block NSString *bAcrRecordEndMethod = [@"acrRecordEnd" stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
//     [LVUtil registryValue:L key:bAcrRecordEndMethod stack:2];
//
//    [VPUPInterfaceDataServiceManager acrRecordEndAndcallback:^(NSString * musicPath) {
//        lua_checkstack32(L);
//        lv_pushNativeObject(L, musicPath);
//        [LVUtil call:L lightUserData:bAcrRecordEndMethod key1:"callback" key2:NULL nargs:1];
//        [LVUtil unregistry:L key:bAcrRecordEndMethod];
//    }];
//}
//return 0;

static int startAcrRecognize(lua_State *L){
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ) {
        VPLACRCloud* acrCloud = (__bridge VPLACRCloud *)(user->object);
        if(acrCloud) {
            //2: MQTT topic qoc
            if( lua_gettop(L) >= 4) {
                
                NSString *key, *secret, *path;
                if (lua_type(L, 3) == LUA_TSTRING) {
                    key = lv_luaValueToNativeObject(L, 3);
                }
                if (lua_type(L, 4) == LUA_TSTRING) {
                    secret = lv_luaValueToNativeObject(L, 4);
                }
                if (lua_type(L, 2) == LUA_TSTRING) {
                    path = lv_luaValueToNativeObject(L, 2);
                }
                Class acrClass = [[VPUPServiceManager sharedManager] serviceImplClass:@protocol(VPUPACRCloudAPIManager)];
                if (acrClass) {
                    [acrClass acrRecognitionMusic:path key:key secret:secret callback:^(NSDictionary * _Nullable dictionary) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lua_checkstack32(L);
                            lv_pushNativeObject(L, dictionary);
                            [LVUtil call:L lightUserData:acrCloud.callBackMethod key1:"callback" key2:NULL nargs:1];
                            [LVUtil unregistry:L key:acrCloud.callBackMethod];
                        });
                    }];
                }
                else {
                    //todo 失败时的处理
                }
            }
        }
    }
    return 0;
}

static int stopAcrRecognize(lua_State *L){
    return 0;
}

static int acrRecordStart(lua_State *L){
    int code = [VPUPInterfaceDataServiceManager acrRecordStart];
    BOOL b = code == 1 ? YES : NO;
    lua_pushboolean(L,b);
    return 1;
}

static int acrRecordEnd(lua_State *L) {
    if (lua_gettop(L) >= 2 && lua_isfunction(L, 2)) {
        __block NSString *bAcrRecordEndMethod = [@"acrRecordEnd" stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
         [LVUtil registryValue:L key:bAcrRecordEndMethod stack:2];
        
        [VPUPInterfaceDataServiceManager acrRecordEndAndcallback:^(NSString * musicPath) {
            lua_checkstack32(L);
            lv_pushNativeObject(L, musicPath);
            [LVUtil call:L lightUserData:bAcrRecordEndMethod key1:"callback" key2:NULL nargs:1];
            [LVUtil unregistry:L key:bAcrRecordEndMethod];
        }];
    }
    return 0;
}

static int acrEnable(lua_State *L){
    Class acrClass = [[VPUPServiceManager sharedManager] serviceImplClass:@protocol(VPUPACRCloudAPIManager)];
    BOOL enable = NO;
    if (acrClass && [VPUPInterfaceDataServiceManager acrDelegateEnable]) {
        enable = YES;
    }
    lua_pushboolean(L, enable);
    return 1;
}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    [LVUtil reg:L clas:self cfunc:lvNewACRCloud globalName:globalName defaultName:@"AcrCloud"];
    
    const struct luaL_Reg memberFunctions [] = {
        { "acrRecognizeCallback", acrRecognizeCallback },
        { "startAcrRecognize", startAcrRecognize },
        { "stopAcrRecognize", stopAcrRecognize },
        { "acrRecordStart", acrRecordStart},
        { "acrRecordEnd", acrRecordEnd},
        { "acrEnable", acrEnable},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L, META_TABLE_NativeObject);
    luaL_openlib(L, NULL, memberFunctions, 0);
    return 1;
}
@end
