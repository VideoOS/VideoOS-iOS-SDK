//
//  VPLWebView.h
//  VideoPlsLuaViewSDK
//
//  Created by Zard1096 on 2017/9/6.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPLWebView.h"

#import "VPUPJsonUtil.h"
#import "VPUPRandomUtil.h"
#import "VPUPMD5Util.h"
#import "VPUPHexColors.h"
#import "VPLBaseNode.h"
#import "VPUPValidator.h"

#import <VPLuaViewSDK/LVBaseView.h>
#import <VPLuaViewSDK/LuaViewCore.h>

typedef NS_ENUM(NSInteger, VPLWebViewCallback) {
    kVPLWebViewOnClose        = 1
};

static char *callbackWebViewKeys[] = { "", "onClose"};

@interface VPLWebView() <VPUPBasicWebViewDelegate, VPLMPWebViewDelegate>

@property (nonatomic) NSDictionary *rootData;

@end

@implementation VPLWebView

-(id)init:(lua_State *)l {
    self = [super init];
    if( self ){
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.delegate = self;
        self.jsMPDelegate = self;
        //默认横屏
        self.landscape = YES;
        VPLBaseNode *luaNode = (id)self.lv_luaviewCore.viewController;
        self.developUserId = luaNode.developerUserId;
        self.mpID = luaNode.mpID;
    }
    return self;
}

- (void)callFromJSMethod:(NSString *)method args:(NSDictionary *)args {
    NSString *methodString = [NSString stringWithFormat:@"%@%@", method, @"WithParameters:"];
    
    SEL selector = NSSelectorFromString(methodString);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:args];
    }
}

- (NSString *)getJSCallback:(NSDictionary *)params {
    if (!VPUP_IsStrictExist([params objectForKey:@"callback"])) {
        return nil;
    }
    
    return [params objectForKey:@"callback"];
}

- (void)getInitDataWithParameters:(NSDictionary *)params {
    NSString *jsCallback = [self getJSCallback:params];
    if (!jsCallback) {
        return;
    }
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    
    NSDictionary *data = self.rootData;
    NSArray *paramArray = nil;
    if (data) {
        [sendParams setObject:data forKey:@"data"];
        
        NSString *sendParamString = VPUP_DictionaryToJson(sendParams);
        
        if (sendParamString) {
            paramArray = [NSArray arrayWithObject:sendParamString];
        }
    }
    
    [self jsCallMethod:jsCallback params:paramArray];
}

- (void)closeViewWithParameters:(NSDictionary *)params {
    lua_State *l = self.lv_luaviewCore.l;
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    [self lv_callLuaCallback:@"onClose"];
    
//    if([LVUtil call:l key1:STR_CALLBACK key2:"onClose" key3:NULL key4:NULL nargs:0 nrets:0 retType:LUA_TNONE] == 0) {
//
//    }
}


- (void)initJSCallMethod {
    lua_State* l = self.lv_luaviewCore.l;
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    //get method name
    if([LVUtil call:l key1:"JSCallMethodString" key2:"method" key3:NULL key4:NULL nargs:0 nrets:1 retType:LUA_TTABLE] == 0) {
        if( lua_type(l, -1)==LUA_TTABLE ) {
            id dict = lv_luaValueToNativeObject(l, -1);
            
            if(dict) {
                if([dict isKindOfClass:[NSArray class]]) {
                    //all method name
                    NSMutableDictionary *jsCallOCDict = [NSMutableDictionary dictionary];
                    for(NSString *methodName in dict) {
                        //组装block
                        __block NSString *bMethodName = methodName;
                        __weak typeof(self) weakSelf = self;
                        
                        VPUPWebViewCallback webViewCallback = ^(id result) {
                            
                            BOOL pushValue = NO;
                            NSString *callbackName = nil;
                            if(result && [result isKindOfClass:[NSString class]]) {
                                //result为jsonString,分为两部分, msg 和 callback
                                id dict = VPUP_JsonToDictionary(result);
                                if(dict && [dict isKindOfClass:[NSDictionary class]]) {
                                    id msg = nil;
                                    NSString *callback = nil;
                                    
                                    if([dict objectForKey:@"msg"]) {
                                        msg = [dict objectForKey:@"msg"];
                                    }
                                    if([dict objectForKey:@"callback"]) {
                                        callback = [dict objectForKey:@"callback"];
                                        if(callback) {
                                            callbackName = callback;
                                        }
                                    }
                                    
                                    if(msg) {
                                        if(!l) {
                                            return;
                                        }
                                        lua_settop(l, 0);
                                        lua_checkstack32(l);
                                        lv_pushNativeObject(l, msg);
                                        pushValue = YES;
                                    }
                                }
                                
                            }
                            
                            lua_State* wl = weakSelf.lv_luaviewCore.l;
                            if(!wl) {
                                return;
                            }
                            
                            lv_pushUserdata(wl, weakSelf.lv_userData);
                            lv_pushUDataRef(wl, USERDATA_KEY_DELEGATE);
                            
                            if([LVUtil call:wl key1:"JSCallMethod" key2:bMethodName.UTF8String key3:NULL key4:NULL nargs:pushValue nrets:1 retType:LUA_TTABLE] == 0) {
                                
                                //return (l, -1)
                                NSString *returnJson = nil;
                                if( lua_type(wl, -1)==LUA_TTABLE ) {
                                    NSDictionary *returnValue = lv_luaValueToNativeObject(wl, -1);
                                    returnJson = VPUP_DictionaryToJson(returnValue);
                                }
                                else if( lua_type(wl, -1)==LUA_TSTRING ) {
                                    //返回就是一个jsonString
                                    returnJson = lv_paramString(wl, -1);
                                }
                                
                                if(callbackName) {
                                    NSArray *params;
                                    if(returnJson) {
                                        params = [NSArray arrayWithObjects:returnJson, nil];
                                    }
                                    [weakSelf nativeCallWebviewWithJS:callbackName paramaters:params callback:nil];
                                }
                            }
                        };
                        
                        if(webViewCallback) {
                            [jsCallOCDict setObject:webViewCallback forKey:methodName];
                        }
                    }
                    
                    [self setJSCallOCDict:jsCallOCDict];
                }
            }
        }
    }
}

- (void)callJSComplete:(id)result requestKey:(NSString *)requestKey {
    if(!requestKey) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        lua_State* l = self.lv_luaviewCore.l;
        if( l ){
            lua_checkstack32(l);
            lv_pushNativeObject(l, result);
            [LVUtil call:l lightUserData:requestKey key1:"callback" key2:NULL nargs:1];
            [LVUtil unregistry :l key:self];
        }
    });
}


- (void)destroyView {
//    [self stopAndRemoveBasicWebview];
    [self stop];
}


#pragma mark webview delegate
- (void)webViewDidStartLoad {
    lua_State *l = self.lv_luaviewCore.l;
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    [self lv_callLuaCallback:@"start"];
//    if([LVUtil call:l key1:STR_CALLBACK key2:"start" key3:NULL key4:NULL nargs:0 nrets:0 retType:LUA_TNONE] == 0) {
//
//    }
}

- (void)loadCompleteWithTitle:(NSString *)title error:(NSError *)error {
    lua_State *l = self.lv_luaviewCore.l;
    
    if(!l) {
        return;
    }
    
    lua_settop(l, 0);
    lua_checkstack(l, 8);
    lua_pushstring(l, title.UTF8String);
    lua_pushstring(l, [error description].UTF8String);
    
    lv_pushUserdata(l, self.lv_userData);
    lv_pushUDataRef(l, USERDATA_KEY_DELEGATE);
    
    
    [self lv_callLuaCallback:@"start" key2:nil argN:2];
//    if([LVUtil call:l key1:STR_CALLBACK key2:"loadComplete" key3:NULL key4:NULL nargs:2 nrets:0 retType:LUA_TNONE] == 0) {
//        
//    }
}


+(int) lvClassDefine:(lua_State *)L globalName:(NSString*)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewWebView globalName:globalName defaultName:@"WebView"];
    const struct luaL_Reg memberFunctions [] = {
        {"initParams",   initParams },
        {"loadUrl",   loadUrl },
        {"callJS",   callJS },
        {"progressColor", progressColor},
        {"isLandscape", isLandscape},
        {"destroyView", destroyView},
        {"setInitData", setInitData },
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_UIWebView);
    luaL_openlib(L, NULL, [LVBaseView baseMemberFunctions], 0);
    luaL_openlib(L, NULL, memberFunctions, 0);
    
    const char* keys[] = { "addView", NULL};// 移除多余API
    lv_luaTableRemoveKeys(L, keys );

    return 1;
}

#pragma mark - C function
//c函数，初始化itemView
static int lvNewWebView (lua_State *L){
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLWebView class]];
    {
        VPLWebView* webView = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, View);
            userData->object = CFBridgingRetain(webView);
            webView.lv_userData = userData;
            luaL_getmetatable(L, META_TABLE_UIWebView );
            lua_setmetatable(L, -2);
            
            if ( lua_gettop(L)>=1 && lua_type(L, 1)==LUA_TTABLE ) {
                lua_pushvalue(L, 1);
                lv_udataRef(L, USERDATA_KEY_DELEGATE );
                
                //错开这次push,到下一次loop中执行
                dispatch_async(dispatch_get_main_queue(), ^{
                    [webView initJSCallMethod];
                });
            }
            
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int initParams (lua_State *L) {
    return lv_setCallbackByKey(L, nil, NO);
}

static int loadUrl(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            if(lua_gettop(L) >= 2) {
                if (lua_isstring(L, 2)) {
                    NSString *url = lv_paramString(L, 2);
                    [webView loadUrl:url];
                }
            }
        }
    }
    return 0;
}

static int progressColor(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            if(lua_gettop(L) >= 2) {
                if (lua_isstring(L, 2)) {
                    NSString *color = lv_paramString(L, 2);
                    [webView setProgressColor:[VPUPHXColor vpup_colorWithHexARGBString:color]];
                }
            }
        }
    }
    return 0;
}

static int isLandscape(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            if(lua_gettop(L) >= 2) {
                if (lua_isboolean(L, 2)) {
                    BOOL isLandscape = lua_toboolean(L, 2);
                    webView.landscape = isLandscape;
                }
            }
        }
    }
    return 0;
}

static int callJS(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            if(lua_gettop(L) >= 2) {
                if (lua_isstring(L, 2)) {
                    NSString *method = lv_paramString(L, 2);
                    
                    NSMutableArray *params = nil;
                    if(lua_gettop(L) >= 3) {
                        if(lua_type(L, 3) == LUA_TTABLE) {
                            NSDictionary *dict = lv_luaValueToNativeObject(L, 3);
                            if(dict && [dict isKindOfClass:[NSDictionary class]]) {
                                NSString *json = VPUP_DictionaryToJson(dict);
                                if(json) {
                                    params = [NSMutableArray arrayWithObjects:json, nil];
                                }
                            }
                        }
                        else if(lua_type(L, 3) == LUA_TSTRING) {
                            //已经为字符串或json
                            NSString *string = lv_paramString(L, 3);
                            if(string) {
                                params = [NSMutableArray arrayWithObjects:string, nil];
                            }
                        }
                    }
                    
                    __block NSString *bRequestMethod = nil;
                    if(lua_gettop(L) >= 4) {
                        if(lua_type(L, 4) == LUA_TFUNCTION) {
                            bRequestMethod = [[VPUPMD5Util md5_16bitHashString:method] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
                            [LVUtil registryValue:L key:bRequestMethod stack:4];
                        }
                    }
                    
                    __weak typeof(webView) weakWebView = webView;
                    [webView nativeCallWebviewWithJS:method paramaters:params callback:^(id result) {
                        [weakWebView callJSComplete:result requestKey:bRequestMethod];
                    }];
                    
                }
            }
        }
    }
    return 0;
}

static int destroyView(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            [webView destroyView];
        }
    }
    return 0;
}

static int setInitData(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLWebView* webView = (__bridge VPLWebView *)(user->object);
        if (webView) {
            if(lua_gettop(L) >= 2) {
                if (lua_istable(L, 2)) {
                    NSDictionary *dict = lv_luaValueToNativeObject(L, 2);
                    webView.rootData = dict;
                }
            }
        }
    }
    return 0;
}

- (id)lv_nativeObject {
    return self;
}

@end
