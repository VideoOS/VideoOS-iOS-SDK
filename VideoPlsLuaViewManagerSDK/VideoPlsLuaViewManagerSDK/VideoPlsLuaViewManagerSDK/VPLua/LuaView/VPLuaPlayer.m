//
//  VPLuaPlayer.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2018/5/10.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLuaPlayer.h"
#import "LVBaseView.h"
#import "LView.h"
#import "LVStyledString.h"
#import "LVHeads.h"
#import <AVFoundation/AVFoundation.h>

@interface VPLuaPlayer () <VPUPVideoClipProtocol>

@end

#define META_TABLE_MediaPlayer "UI.MediaPlayer"

@implementation VPLuaPlayer

- (id)init:(lua_State *)l {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);// 获取luaview运行内核
        self.clipsToBounds = YES;// 默认出界不可见
        self.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    [self updateCurrentPlayerVolume:[[AVAudioSession sharedInstance] outputVolume]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    lua_State* l = self.lv_luaviewCore.l;
    if( l ){
        lua_pushnumber(l, volume);
    }
    [self lv_callLuaCallback:@"onChangeVolume" key2:nil argN:1];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }
    return hitView;
}

#pragma -mark VPLuaPlayer
/*
 * lua脚本中 local player = Player() 对应的构造方法
 */
static int lvNewPlayer(lua_State *L) {
    // 获取构造方法对应的Class(Native类)
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaPlayer class]];
    {
        VPLuaPlayer* player = [[c alloc] init:L];//通过Class和参数构造脚本对应的真实实例
        {
            NEW_USERDATA(userData, View);// 创建lua对象(userdata)
            userData->object = CFBridgingRetain(player);// 脚本对象引用native对象
            player.lv_userData = userData;//native对象引用脚本对象
            
            luaL_getmetatable(L, META_TABLE_MediaPlayer ); // 获取VPLuaPlayer对应的类方法列表
            lua_setmetatable(L, -2); // 设置刚才创建的lua对象的方法列表是类Player的方法列表
        }
        LuaViewCore* view = LV_LUASTATE_VIEW(L);// 获取当前LuaView对应的LuaViewCore
        if (view) {
            [view containerAddSubview:player]; // 把player对象加到LuaViewCore里面
        }
    }
    return 1; // 返回参数的个数
}

static int callback (lua_State *L) {
    return lv_setCallbackByKey(L, nil, NO);
}

static int source (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( lua_gettop(L)>=2 ) {
            // 两个参数: 第一个对象自身, 第二个参数url
            NSString *url = lv_paramString(L, 2);// 2
            if( [player isKindOfClass:[VPLuaPlayer class]] ){
                VPUPVideo *video = [[VPUPVideo alloc] init];
                video.url = [NSURL URLWithString:url];
                player.videoArray = @[video];
                return 0;
            }
        } else {
            // 脚本层无入参(除了self), 则返回url
            if (player.videoArray.count > 0) {
                VPUPVideo *video = [player.videoArray objectAtIndex:0];
                lua_pushstring(L, [video.url.absoluteString UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int videoPlay (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            if( lua_gettop(L)>=2 ) {
                // 两个参数: 第一个对象自身, 第二个参数url
                NSString *url = lv_paramString(L, 2);// 2
                if( [player isKindOfClass:[VPLuaPlayer class]] ){
                    VPUPVideo *video = [[VPUPVideo alloc] init];
                    video.url = [NSURL URLWithString:url];
                    player.videoArray = @[video];
                }
            }
            [player play];
            return 0;
        }
    }
    return 0;
}

static int videoPause (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            [player pause];
            return 0;
        }
    }
    return 0;
}

static int restartPlay (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            [player play];
            return 0;
        }
    }
    return 0;
}

static int duration (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            lua_pushnumber(L, player.currentPlayerItemDuration * 1000.0);
            return 1;
        }
    }
    return 0;
}

static int position (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            lua_pushnumber(L, player.currentPlayerItemTime * 1000.0);
            return 1;
        }
    }
    return 0;
}

static int status (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            lua_pushnumber(L, player.status);
            return 1;
        }
    }
    return 0;
}

static int voice (lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);// 获取第一个参数(self,lua的userdata, 对象自身)
    if (user) {
        VPLuaPlayer *player = (__bridge VPLuaPlayer *)(user->object);// 获取self对应的native对象
        if( [player isKindOfClass:[VPLuaPlayer class]] ){
            if( lua_gettop(L)>=2 ) {
                // 两个参数: 第一个对象自身, 第二个参数Volume
                CGFloat volume = lua_tonumber(L, 2);
                [player updateCurrentPlayerVolume:volume];
            }
            else {
                lua_pushnumber(L, player.volume);
                return 1;
            }
        }
    }
    return 0;
}

/*
 * luaview所有扩展类的桥接协议: 只是一个静态协议, luaview统一调用该接口加载luaview扩展的类
 */
+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *) globalName{
    // 注册构造方法: "Player" 对应的C函数(lvNewPlayer) + 对应的类Class(self/LVLabel)
    [LVUtil reg:L clas:self cfunc:lvNewPlayer globalName:globalName defaultName:@"MediaPlayer"];
    
    // lua Player构造方法创建的对象对应的方法列表
    const struct luaL_Reg memberFunctions [] = {
        
        {"callback", callback},
        {"status", status},
        {"position", position},
        {"source", source},
        {"startPlay", videoPlay},
        {"stopPlay", videoPause},
        {"pausePlay", videoPause},
        {"restartPlay", restartPlay},
        {"duration", duration},
        {"voice", voice},
        {NULL, NULL}
    };
    
    // 创建Player类的方法列表
    lv_createClassMetaTable(L, META_TABLE_MediaPlayer);
    
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0); // 继承基类View的所有方法列表
    luaL_openlib(L, NULL, memberFunctions, 0); // 当前类Label特有的方法列表
    
    const char* keys[] = { "addView", NULL};//列出需要移除的多余API
    lv_luaTableRemoveKeys(L, keys );// 移除冗余API 兼容安卓
    return 1;
}

/*
 * 脚本中print(obj)的时候会调用该接口 显示该对象的相关信息
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"<Player(0x%x) frame = %@>", (int)[self hash], NSStringFromCGRect(self.frame)];
}

- (void)videoClipVideoPreparePlaying:(NSUInteger)index videoUrl:(NSURL *)url {
    [self lv_callLuaCallback:@"onPrepare" key2:nil argN:0];
}

- (void)videoClipVideoStartPlaying:(NSUInteger)index videoUrl:(NSURL *)url {
    [self lv_callLuaCallback:@"onStart" key2:nil argN:0];
}

- (void)videoClipVideoFinished:(NSUInteger)index videoUrl:(NSURL *)url {
    [self lv_callLuaCallback:@"onFinished" key2:nil argN:0];
}

- (void)videoClipAllFinished {
    [self lv_callLuaCallback:@"onFinished" key2:nil argN:0];
}

- (void)videoClipDidClick:(NSUInteger)index videoUrl:(NSURL *)url {
    NSLog(@"videoClipDidClick");
    [self lv_callLuaCallback:@"onClick" key2:nil argN:0];
}

- (void)videoClipCurrentVideoIndex:(NSUInteger)index url:(NSURL *)url timePlayed:(NSTimeInterval)timePlayed totalTime:(NSTimeInterval)totalTime {
    
}

- (void)videoClipDidLoadError:(NSError *)error {
    [self lv_callLuaCallback:@"onError" key2:nil argN:0];
}

@end
