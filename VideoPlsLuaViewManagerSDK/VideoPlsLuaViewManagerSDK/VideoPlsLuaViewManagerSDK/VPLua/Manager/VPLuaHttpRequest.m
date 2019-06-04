//
//  VPLuaHttpRequest.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/5/7.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHttpRequest.h"
#import "VPLuaBaseNode.h"
#import <VPLuaViewSDK/LVStruct.h>
#import <VPLuaViewSDK/LuaViewCore.h>
#import <VPLuaViewSDK/LVUtil.h>
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPLuaNetworkManager.h"
#import "VPUPMD5Util.h"
#import "VPUPRandomUtil.h"
#import "VPUPUrlUtil.h"

@interface VPLuaHttpRequest()

@property (nonatomic, strong) NSMutableDictionary *apisCache;
@property (nonatomic, strong) NSMutableDictionary *apiIdToMethodKey;

@end

@implementation VPLuaHttpRequest

-(id) init:(lua_State *)l {
    self = [super init];
    if ( self ) {
        self.lv_luaviewCore = LV_LUASTATE_VIEW(l);
        self.luaNode = (id)self.lv_luaviewCore.viewController;
        self.apisCache = [NSMutableDictionary dictionaryWithCapacity:0];
        self.apiIdToMethodKey = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(id) lv_nativeObject{
    return self;
}

- (void)dealloc {
    NSLog(@"VPLuaHttpRequest dealloc");
}

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString *)globalName {
    [LVUtil reg:L clas:self cfunc:lvNewHttpRequest globalName:globalName defaultName:@"HttpRequest"];
    
    const struct luaL_Reg staticFunctions [] = {
        
        {"post", post},
        {"get", get},
        {"put", put},
        {"delete", delete},
        {"abort", cancel},
        {"abortAll", cancelAll},
        {"upload", upload},
        {NULL, NULL}
    };
    
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    
    luaL_openlib(L, NULL, staticFunctions, 0);
    
    return 1;
}

static int lvNewHttpRequest(lua_State *L) {
    Class c = [LVUtil upvalueClass:L defaultClass:[VPLuaHttpRequest class]];
    {
        VPLuaHttpRequest* request = [[c alloc] init:L];
        {
            NEW_USERDATA(userData, NativeObject);
            userData->object = CFBridgingRetain(request);
            request.lv_userData = userData;
            
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

static int post(lua_State *L) {
    return httpRequest(L, VPUPRequestMethodTypePOST);
}

static int get(lua_State *L) {
    return httpRequest(L, VPUPRequestMethodTypeGET);
}

static int delete(lua_State *L) {
    return httpRequest(L, VPUPRequestMethodTypeDELETE);
}

static int put(lua_State *L) {
    return httpRequest(L, VPUPRequestMethodTypePUT);
}

static int cancel(lua_State *L) {
    
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaHttpRequest* request = (__bridge VPLuaHttpRequest *)(user->object);
        if( [request isKindOfClass:[VPLuaHttpRequest class]] ){
            if(lua_gettop(L) >= 2) {
                NSString *apiId = [NSString stringWithFormat:@"%ld",(NSUInteger)lua_tointeger(L, 2)];
                VPUPHTTPBusinessAPI *api = [request.apisCache objectForKey:apiId];
                if (api) {
                    [request.apisCache removeObjectForKey:apiId];
                    if([request.apiIdToMethodKey objectForKey:apiId]) {
                        [LVUtil unregistry:L key:[request.apiIdToMethodKey objectForKey:apiId]];
                    }
                    [[VPLuaNetworkManager Manager].httpManager cancelAPIRequest:api];
                }
            }
        }
    }
    return 0;
}

static int cancelAll(lua_State *L) {
    [[VPLuaNetworkManager Manager].httpManager cancelAll];
    return 0;
}

static int httpRequest(lua_State *L, VPUPRequestMethodType methodType) {
    
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaHttpRequest* request = (__bridge VPLuaHttpRequest *)(user->object);
        if( [request isKindOfClass:[VPLuaHttpRequest class]] ){
            
            //2: url(需要拆分), 4:parameters, 5:callback
            int argN = lua_gettop(L);
            if(argN >= 2) {
                NSString *url = nil;
                NSString *baseUrl = nil;
                NSString *requestMethod = nil;
                NSDictionary* data = nil;
                
                if(lua_isstring(L, 2)) {
                    url = lv_paramString(L, 2);
                }
                
                if (!url) {
                    return 0;
                }
                
                url = [VPUPUrlUtil urlencode:url];
                
                baseUrl = [[NSURL URLWithString:@"/" relativeToURL:[NSURL URLWithString:url]].absoluteString copy];
                requestMethod = [url stringByReplacingOccurrencesOfString:baseUrl withString:@""];
                
                //重组function的key,保证不重复
                __block NSString *bRequestMethod = [[VPUPMD5Util md5_16bitHashString:url] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
                
                //上报默认为YES
                __block BOOL needReport = YES;
                
                BOOL needToCheck = NO;
                __weak NSObject *handleObject = nil;
                BOOL needToCallBack = NO;
                
                for(int i = 3; i <= argN; i++) {
                    int type = lua_type(L, i);
                    if( type == LUA_TTABLE ) {// 数据
                        data = lv_luaTableToDictionary(L, i);
                    }
                    
                    if( type == LUA_TFUNCTION ) {
                        [LVUtil registryValue:L key:bRequestMethod stack:i];
                        needToCallBack = YES;
                    }
                    
                    if (type == LUA_TBOOLEAN) {
                        //可能多一个参数, 为bool, 是否需要report
                        needReport = lua_toboolean(L, i);
                    }
                    
                    if (type == LUA_TUSERDATA) {
                        //判定发起网络请求的页面是否释放
                        LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, i);
                        if (user) {
                            handleObject = (__bridge NSObject *)user->object;
                            needToCheck = YES;
                        }
                    }
                }
                
                VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
                api.baseUrl = baseUrl;
                api.requestMethod = requestMethod;
                api.apiRequestMethodType = methodType;
                [api setRequestParameters:data];
                __weak VPLuaHttpRequest *weakRequest = request;
                NSString *apiId = [NSString stringWithFormat:@"%ld",api.apiId];
                api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
                    
                    if (!weakRequest) {
                        return;
                    }
                    
                    if ([weakRequest.apisCache objectForKey:apiId]) {
                        [weakRequest.apisCache removeObjectForKey:apiId];
                    }
                    //request 已经cancel
                    else {
                        return;
                    }
                    
                    //没有回调，网络请求不处理回调
                    if (!needToCallBack) {
                        return;
                    }
                    
                    if (needToCheck) {
                        if (!handleObject) {
                            return;
                        }
                    }
                    
                    if (!needReport) {
                        NSString *gifString = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Type"];
                        if ([gifString isEqualToString:@"image/gif"]) {
                            return;
                        }
                        return;
                    }
                    
                    lua_State* l = L;
                    if( l ){
                        lua_checkstack32(l);
                        lv_pushNativeObject(l, responseObject);
                        NSString *errorInfo = [error description];
                        lv_pushNativeObject(l, errorInfo);
                        [LVUtil call:l lightUserData:bRequestMethod key1:"callback" key2:NULL nargs:2];
                        [LVUtil unregistry :l key:bRequestMethod];
                    }
                };
                [request.apisCache setObject:api forKey:apiId];
                [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
                lua_pushinteger(L, api.apiId);
                [request.apiIdToMethodKey setObject:bRequestMethod forKey:apiId];
                return 1;
            }
        }
    }
    return 0;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    NSString *defaultType = @"file";
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return defaultType;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return defaultType;
    }
    return defaultType;
}

static int upload(lua_State *L) {
    LVUserDataInfo *user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        VPLuaHttpRequest* request = (__bridge VPLuaHttpRequest *)(user->object);
        if( [request isKindOfClass:[VPLuaHttpRequest class]] ){
            
            //2: requestUrl, 3:filepath, 4:callback
            int argN = lua_gettop(L);
            if(argN >= 2) {
                NSString *requestUrl = nil;
                NSString *filepath = nil;
                
                if(lua_isstring(L, 2)) {
                    requestUrl = lv_paramString(L, 2);
                }
                if(lua_isstring(L, 3)) {
                    filepath = lv_paramString(L, 3);
                }
                
                requestUrl = [VPUPUrlUtil urlencode:requestUrl];
                
                //重组function的key,保证不重复
                __block NSString *bRequestMethod = [[VPUPMD5Util md5_16bitHashString:[NSString stringWithFormat:@"%@%@", requestUrl, filepath]] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
                [LVUtil registryValue:L key:bRequestMethod stack:4];
                
                VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
                api.customRequestUrl = requestUrl;
                api.apiRequestMethodType = VPUPRequestMethodTypePOST;
                __weak VPLuaHttpRequest *weakRequest = request;
                NSString *apiId = [NSString stringWithFormat:@"%ld",api.apiId];
                api.apiRequestConstructingBodyBlock = ^(id<VPUPMultipartFormData> _Nonnull formData) {
                    
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
                    NSString *fileType = [VPLuaHttpRequest contentTypeForImageData:data];
                    NSString *mineType = nil;
                    if ([fileType isEqualToString:@"file"]) {
                        //It need fix other type
                        mineType = @"application/zip";
                    }
                    else {
                        mineType = [NSString stringWithFormat:@"image/%@",fileType];
                    }
                    
                    [formData appendPartWithFileData:data name:@"file" fileName:[filepath lastPathComponent] mimeType:mineType];
                };
                
                api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
                    
                    if (!weakRequest) {
                        return;
                    }
                    
                    if ([weakRequest.apisCache objectForKey:apiId]) {
                        [weakRequest.apisCache removeObjectForKey:apiId];
                    }
                    //request 已经cancel
                    else {
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        lua_State* l = L;
                        if( l ){
                            lua_checkstack32(l);
                            lv_pushNativeObject(l, responseObject);
                            NSString *errorInfo = [error description];
                            lv_pushNativeObject(l, errorInfo);
                            [LVUtil call:l lightUserData:bRequestMethod key1:"callback" key2:NULL nargs:2];
                            [LVUtil unregistry :l key:bRequestMethod];
                        }
                    });
                    //            [weakCell apiComplete:responseObject error:error response:response requestMethod:bRequestMethod];
                };
                [request.apisCache setObject:api forKey:apiId];
                [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
                lua_pushinteger(L, api.apiId);
                [request.apiIdToMethodKey setObject:bRequestMethod forKey:apiId];
                return 1;
            }
        }
    }
    return 0;
}

@end
