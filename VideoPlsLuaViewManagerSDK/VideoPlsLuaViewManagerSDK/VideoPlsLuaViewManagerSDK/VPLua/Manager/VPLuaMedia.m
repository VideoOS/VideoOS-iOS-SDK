//
//  VPLuaMedia.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 09/02/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaMedia.h"
#import "VPLuaBaseNode.h"
#import "LVStruct.h"
#import "LuaViewCore.h"
#import "LVUtil.h"
#import <VideoPlsUtilsPlatformSDK/VPUPInterfaceDataServiceManager.h>
#import <VideoPlsUtilsPlatformSDK/VPUPLifeCycle.h>
#import <VideoPlsUtilsPlatformSDK/VPUPNotificationCenter.h>

NSString *const VPLuaMediaStartNotification = @"VPLuaMediaStartNotification";
NSString *const VPLuaMediaPlayNotification = @"VPLuaMediaPlayNotification";
NSString *const VPLuaMediaPauseNotification = @"VPLuaMediaPauseNotification";
NSString *const VPLuaMediaEndNotification = @"VPLuaMediaEndNotification";
NSString *const VPLuaMediaPlayerSizeNotification = @"VPLuaMediaPlayerSizeNotification";
NSString *const VPLuaMediaStartTimeNotification = @"VPLuaMediaStartTimeNotification";
NSString *const VPLuaMediaStopTimeNotification = @"VPLuaMediaStopTimeNotification";

typedef NS_ENUM(NSInteger, VPLuaMediaCallback) {
    kVPLuaMediaCallbackOnPlay = 1,
    kVPLuaMediaCallbackOnPause,
    kVPLuaMediaCallbackOnEnd,
    kVPLuaMediaCallbackOnProgress,
    kVPLuaMediaCallbackOnPlayerSize
};

static char *callbackMediaKeys[] = { "", "onMediaPlay", "onMediaPause", "onMediaEnd", "onMediaProgress", "onPlayerSize" };

@interface VPLuaProxy : NSProxy

@property (nonatomic,weak) id obj;

@end

@implementation VPLuaProxy

/**
 这个函数让重载方有机会抛出一个函数的签名，再由后面的forwardInvocation:去执行
 为给定消息提供参数类型信息
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *sig = nil;
    sig = [self.obj methodSignatureForSelector:aSelector];
    return sig;
}

/**
 *  NSInvocation封装了NSMethodSignature，通过invokeWithTarget方法将消息转发给其他对象.这里转发给控制器执行。
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [anInvocation invokeWithTarget:self.obj];
}

@end

@interface VPLuaMedia()

@property (nonatomic, strong) VPLuaProxy *proxy;
@property (nonatomic, strong) NSTimer *mediaProgressTimer;
@property (nonatomic, assign) NSTimeInterval lastProgress;

@end

@implementation VPLuaMedia

-(id) init:(lua_State *)l {
    self = [super init];
    if ( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.luaNode = (id)self.lv_luaviewCore.viewController;
        self.proxy = [VPLuaProxy alloc];
        self.proxy.obj = self;
        [self registerNotification];
    }
    return self;
}

-(id) lv_nativeObject{
    return self;
}

#pragma mark media notification
- (void)mediaDidPause {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLuaMediaCallbackOnPause];
    });
}

- (void)mediaDidPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLuaMediaCallbackOnPlay];
    });
}

- (void)mediaDidEnd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLuaMediaCallbackOnEnd];
    });
}

- (void)mediaPlayerSize:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLuaMediaCallbackOnPlayerSize userInfo:userInfo];
    });
}

- (void)startMediaProgressTimer {
    if (!_mediaProgressTimer) {
        _mediaProgressTimer = [NSTimer timerWithTimeInterval:0.1 target:self.proxy selector:@selector(updateMediaProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_mediaProgressTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updateMediaProgress {
    if (self.lastProgress != [VPUPInterfaceDataServiceManager videoPlayerCurrentTime] * 1000) {
        self.lastProgress = [VPUPInterfaceDataServiceManager videoPlayerCurrentTime] * 1000;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callback:kVPLuaMediaCallbackOnProgress progress:[VPUPInterfaceDataServiceManager videoPlayerCurrentTime]*1000.0];
        });
    }
}

- (void)stopMediaProgressTimer {
    if (_mediaProgressTimer) {
        [_mediaProgressTimer invalidate];
        _mediaProgressTimer = nil;
    }
}

- (void)videoStop:(NSNotification *)sender {
    [self stopMediaProgressTimer];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDidPause) name:VPLuaMediaPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDidPlay) name:VPLuaMediaPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaDidEnd) name:VPLuaMediaEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerSize:) name:VPLuaMediaPlayerSizeNotification object:nil];
}

- (void)deregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaMediaPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaMediaPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaMediaEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VPLuaMediaPlayerSizeNotification object:nil];
}

- (void)dealloc {
    [self stopMediaProgressTimer];
    [self deregisterNotification];
}

- (void)callback:(VPLuaMediaCallback)idx {
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

- (void)callback:(VPLuaMediaCallback)idx progress:(NSTimeInterval)progress {
    lua_State* l = self.lv_luaviewCore.l;
    if (l && self.lv_userData) {
        int stackIndex = lua_gettop(l);
    
        lua_pushnumber(l, progress);
        lv_pushUserdata(l, self.lv_userData);
        lv_pushUDataRef(l, idx);
        lv_runFunctionWithArgs(l, 1, 0);

        if (lua_gettop(l) > stackIndex) {
            lua_settop(l, stackIndex);
        }
    }
}

- (void)callback:(VPLuaMediaCallback)idx userInfo:(NSDictionary *)userInfo {
    lua_State* l = self.lv_luaviewCore.l;
    if (l && self.lv_userData) {
        int stackIndex = lua_gettop(l);
        CGFloat width = [[userInfo objectForKey:@"width"] floatValue];
        CGFloat height = [[userInfo objectForKey:@"height"] floatValue];
        NSInteger type = [[userInfo objectForKey:@"orientation"] integerValue];
        lua_pushnumber(l, type);
        lua_pushnumber(l, width);
        lua_pushnumber(l, height);
        lv_pushUserdata(l, self.lv_userData);
        lv_pushUDataRef(l, idx);
        lv_runFunctionWithArgs(l, 3, 0);
        
        if (lua_gettop(l) > stackIndex) {
            lua_settop(l, stackIndex);
        }
    }
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
//    return vplv_setCallbackByKey(L, NULL);
//}
static int onMediaPause (lua_State *L) {
    return setCallback(L, kVPLuaMediaCallbackOnPause);
}

static int onMediaPlay (lua_State *L) {
    return setCallback(L, kVPLuaMediaCallbackOnPlay);
}

static int onMediaEnd (lua_State *L) {
    return setCallback(L, kVPLuaMediaCallbackOnEnd);
}

static int isMediaPlaying (lua_State *L) {
    lua_pushboolean(L, YES);
    return 1;
}

static int onMediaProgress (lua_State *L) {
    NSTimeInterval progress = [VPUPInterfaceDataServiceManager videoPlayerCurrentTime];
    lua_pushnumber(L, progress);
    return 1;
}

static int onPlayerSize (lua_State *L) {
    return setCallback(L, kVPLuaMediaCallbackOnPlayerSize);
}

static int destroyMedia (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaMedia* media = (__bridge VPLuaMedia *)(user->object);
        if( [media isKindOfClass:[VPLuaMedia class]] ){
            [media stopMediaProgressTimer];
        }
    }
    return 0;
}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewMedia globalName:globalName defaultName:@"Media"];
    
    const struct luaL_Reg staticFunctions [] = {
        { "mediaCallback", mediaCallback },
        { callbackMediaKeys[kVPLuaMediaCallbackOnPlay], onMediaPlay },
        { callbackMediaKeys[kVPLuaMediaCallbackOnPause], onMediaPause },
        { callbackMediaKeys[kVPLuaMediaCallbackOnEnd], onMediaEnd },
        { callbackMediaKeys[kVPLuaMediaCallbackOnProgress], onMediaProgress},
        { callbackMediaKeys[kVPLuaMediaCallbackOnPlayerSize], onPlayerSize},
        { "destroyMedia", destroyMedia},
        { "startVideoTime", startVideoTime},
        { "stopVideoTime", stopVideoTime},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    
    luaL_openlib(L, NULL, staticFunctions, 0);
    
    return 1;
}

static int lvNewMedia(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaMedia class]];
    {
        VPLuaMedia* media = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, NativeObject);
            userData->object = CFBridgingRetain(media);
            media.lv_userData = userData;
            
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

static int mediaCallback(lua_State *L) {
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
            for (int i = 0; i < sizeof(callbackMediaKeys) / sizeof(callbackMediaKeys[0]); ++i) {
                if (strcmp(key, callbackMediaKeys[i]) == 0) {
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

static int startVideoTime(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaMedia* media = (__bridge VPLuaMedia *)(user->object);
        if( [media isKindOfClass:[VPLuaMedia class]] ){
            [media startMediaProgressTimer];
        }
    }
    return 0;
}

static int stopVideoTime(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaMedia* media = (__bridge VPLuaMedia *)(user->object);
        if( [media isKindOfClass:[VPLuaMedia class]] ){
            [media stopMediaProgressTimer];
        }
    }
    return 0;
}

@end
