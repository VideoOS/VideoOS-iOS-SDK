//
//  VPLSVGAView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 26/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLSVGAView.h"
#import <VPLuaViewSDK/LVBaseView.h>
#import <VPLuaViewSDK/LView.h>
#import <VPLuaViewSDK/LVStyledString.h>
#import <VPLuaViewSDK/LVHeads.h>
#import "VideoPlsUtilsPlatformSDK.h"


typedef NS_ENUM(NSInteger, VPLSVGAViewCallback) {
    kVPLSVGAViewCallbackOnFinished = 1,
    kVPLSVGAViewCallbackOnStep
};

static char *callbackSVGAViewKeys[] = { "", "onFinished", "onStep"};


@interface VPLSVGAView () <VPUPSVGAPlayerDelegate>

@property (nonatomic, strong) id<VPUPSVGAPlayerProtocol> player;

@end

@implementation VPLSVGAView

-(id) init:(lua_State*) l{
    self = [super init];
    if( self ){
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);// 获取luaview运行内核
        self.player = [VPUPSVGAPlayerFactory createSVGAPlayerWithType:VPUPSVGAPlayerTypeCustom];
        if (self.player) {
            [self addSubview:self.player.view];
            self.player.view.frame = self.bounds;
            self.player.delegate = self;
        }
    }
    return self;
}

-(void) dealloc{
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.player.view.frame = self.bounds;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.player.view) {
        return nil;
    }
    return hitView;
}

#pragma -mark VPLSVGAView
/*
 * lua脚本中 local svgaView = SVGAView() 对应的构造方法
 */
static int lvNewSVGAView(lua_State *L) {
    // 获取构造方法对应的Class(Native类)
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLSVGAView class]];
    {
        VPLSVGAView* svgaView = [[c alloc] init:L];//通过Class和参数构造脚本对应的真实实例
        {
            NEW_USERDATA(userData, View);// 创建lua对象(userdata)
            userData->object = CFBridgingRetain(svgaView);// 脚本对象引用native对象
            svgaView.lv_userData = userData;//native对象引用脚本对象
            
            luaL_getmetatable(L, META_TABLE_UIView); // 获取svgaView对应的类方法列表
            lua_setmetatable(L, -2); // 设置刚才创建的lua对象的方法列表是类svgaView的方法列表
        }
        LuaViewCore* view = LV_LUASTATE_VIEW(L);// 获取当前LuaView对应的LuaViewCore
        if( view ){
            [view containerAddSubview:svgaView]; // 把svgaView对象加到LuaViewCore里面
        }
    }
    return 1; // 返回参数的个数
}

static int loops (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个参数loops
            int loops = (int)lua_tonumber(L, 2);// 2
            if( [view isKindOfClass:[VPLSVGAView class]] ){
                view.player.loops = loops;
                return 0;
            }
        } else {
            // 脚本层无入参(除了self), 则返回loops
            int loops = view.player.loops;
            lua_pushnumber(L, loops);
            return 1;
        }
    }
    return 0;
}

static int readyToPlay (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        // 脚本层无入参(除了self), 则返回readyToPlay
        bool readyToPlay = view.player.readyToPlay;
        lua_pushboolean(L, readyToPlay);
        return 1;
    }
    return 0;
}

static int fps (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        // 脚本层无入参(除了self), 则返回fps
        int fps = view.player.fps;
        lua_pushnumber(L, fps);
        return 1;
    }
    return 0;
}

static int frames (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        // 脚本层无入参(除了self), 则返回frames
        int frames = view.player.frames;
        lua_pushnumber(L, frames);
        return 1;
    }
    return 0;
}

static int svga (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个参数url,第三个参数callback
            NSString* path = lv_paramString(L, 2);// 2
            
            void(^loadComplete)(void) = nil;
            if (lua_gettop(L) >= 3 && lua_type(L, 3) == LUA_TFUNCTION) {
                __block NSString *loadCompleteMethod = [[VPUPMD5Util md5_16bitHashString:path] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
                [LVUtil registryValue:L key:loadCompleteMethod stack:3];
                loadComplete = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(L){
                            [LVUtil call:L lightUserData:loadCompleteMethod key1:"callback" key2:NULL nargs:0];
                            [LVUtil unregistry:L key:loadCompleteMethod];
                        }
                    });
                };
            }
            
            if( [view isKindOfClass:[VPLSVGAView class]] ){
                if ([path containsString:@"http://"] || [path containsString:@"https://"]) {
                    [view.player setSVGAWithURL:[NSURL URLWithString:path] readyToPlay:loadComplete];
                }
                else
                {
                    [view.player setSVGAWithData:[NSData dataWithContentsOfFile:path] cacheKey:path readyToPlay:loadComplete];
                }
                return 0;
            }
        }
    }
    return 0;
}

static int svgaCallback(lua_State *L) {
    LVUserDataInfo *data = (LVUserDataInfo *)lua_touserdata(L, 1);
    if (LVIsType(data, View) && lua_type(L, 2) == LUA_TTABLE) {
        lua_pushvalue(L, 2);
        lua_pushnil(L);
        
        while (lua_next(L, -2)) {
            if (lua_type(L, -2) != LUA_TSTRING) {
                continue;
            }
            const char* key = lua_tostring(L, -2);
            int idx = 0;
            for (int i = 0; i < sizeof(callbackSVGAViewKeys) / sizeof(callbackSVGAViewKeys[0]); ++i) {
                if (strcmp(key, callbackSVGAViewKeys[i]) == 0) {
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

static int startAnimation (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            if( lua_gettop(L)>=2 && lua_type(L, 2) == LUA_TTABLE) {
                // 两个参数: 第一个对象自身, 第二个参数Range
                NSDictionary *data = lv_luaTableToDictionary(L, 2);
                [view.player startAnimationWithRange:NSMakeRange([[data objectForKey:@"location"] integerValue], [[data objectForKey:@"length"] integerValue]) reverse:NO];
            }
            else
            {
                [view.player startAnimation];
            }
            return 0;
        }
    }
    return 0;
}

static int pauseAnimation (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            [view.player pauseAnimation];
            return 0;
        }
    }
    return 0;
}

static int stopAnimation (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            [view.player stopAnimation];
            return 0;
        }
    }
    return 0;
}

static int stepToFrame (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            if( lua_gettop(L) >= 3) {
                // 三个参数: 第一个对象自身, 第二个参数frame，第三个参数play
                NSInteger frame = lua_tointeger(L, 2);
                BOOL isPlay = lua_toboolean(L, 3);
                [view.player stepToFrame:frame andPlay:isPlay];
            }
        }
    }
    return 0;
}

static int stepToPercentage (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            if( lua_gettop(L) >= 3) {
                // 三个参数: 第一个对象自身, 第二个参数百分比，第三个参数play
                CGFloat percentage = lua_tonumber(L, 2);
                BOOL isPlay = lua_toboolean(L, 3);
                [view.player stepToPercentage:percentage andPlay:isPlay];
            }
        }
    }
    return 0;
}

static int isAnimating (lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if( user ){
        VPLSVGAView* view = (__bridge VPLSVGAView *)(user->object);// 获取self对应的native对象
        if( [view isKindOfClass:[VPLSVGAView class]] ){
            BOOL isAnimating = view.player.isAnimating;
            lua_pushboolean(L, isAnimating);
            return 1;
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

static int onFinished (lua_State *L) {
    return setCallback(L, kVPLSVGAViewCallbackOnFinished);
}

static int onStep (lua_State *L) {
    return setCallback(L, kVPLSVGAViewCallbackOnStep);
}

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
    // 注册构造方法: "svgaView" 对应的C函数(lvNewSVGAView) + 对应的类Class(self/VPLSVGAView)
    [LVUtil reg:L clas:self cfunc:lvNewSVGAView globalName:globalName defaultName:@"SVGAView"];
    
    // lua SVGAView构造方法创建的对象对应的方法列表
    const struct luaL_Reg memberFunctions [] = {
        
        {"loops",    loops},
        {"readyToPlay",    readyToPlay},
        {"fps",    fps},
        {"frames",    frames},
        {"svga",    svga},
        {"startAnimation",    startAnimation},
        {"pauseAnimation",    pauseAnimation},
        {"stopAnimation",    stopAnimation},
        {"stepToFrame",    stepToFrame},
        {"stepToPercentage",    stepToPercentage},
        {"isAnimating", isAnimating },
        {"svgaCallback",    svgaCallback},
        { callbackSVGAViewKeys[kVPLSVGAViewCallbackOnFinished], onFinished },
        { callbackSVGAViewKeys[kVPLSVGAViewCallbackOnStep], onStep },
        {NULL, NULL}
    };
    
    // 创建SVGAView类的方法列表
    lv_createClassMetaTable(L, META_TABLE_UIView);
    
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0); // 继承基类View的所有方法列表
    luaL_openlib(L, NULL, memberFunctions, 0); // 当前类SVGAView特有的方法列表
    return 1;
}

- (void)svgaPlayerDidFinishedAnimation:(id<VPUPSVGAPlayerProtocol>)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLSVGAViewCallbackOnFinished];
    });
}

- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callback:kVPLSVGAViewCallbackOnStep progress:frame];
    });
}

- (void)callback:(VPLSVGAViewCallback)idx {
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

- (void)callback:(VPLSVGAViewCallback)idx progress:(NSInteger)progress {
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

/*
 * 脚本中print(obj)的时候会调用该接口 显示该对象的相关信息
 */
-(NSString*) description{
    return [NSString stringWithFormat:@"<SVGAView(0x%x) frame = %@>", (int)[self hash], NSStringFromCGRect(self.frame) ];
}

@end
