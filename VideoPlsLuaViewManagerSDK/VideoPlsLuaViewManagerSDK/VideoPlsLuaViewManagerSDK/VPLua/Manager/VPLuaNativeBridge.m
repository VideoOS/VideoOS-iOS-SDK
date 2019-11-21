//
//  VPLuaNativeBridge.m
//  VideoPlsLuaViewSDK
//
//  Created by 鄢江波 on 2017/8/11.
//  Copyright © 2017年 李少帅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "VPLuaNativeBridge.h"
#import "VPLuaNodeController.h"
#import "VPLuaVideoInfo.h"
#import "VPLuaBaseNode.h"

#import <VPLuaViewSDK/LVUtil.h>
#import <VPLuaViewSDK/LVStruct.h>
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPUPHTTPManagerFactory.h"
#import "VPUPActionManager.h"
#import "VPUPGZIPUtil.h"
#import "VPUPAESUtil.h"
#import "VPUPBase64Util.h"
#import "VPUPGeneralInfo.h"
#import "VPUPMD5Util.h"
#import "VPUPGeneralInfo.h"
#import "VPUPDebugSwitch.h"
#import "VPUPJsonUtil.h"
#import <VPLuaViewSDK/LVZipArchive.h>
#import "VPLuaMQTT.h"
#import "VPLuaMedia.h"
#import "VPUPDeviceUtil.h"
#import "VPUPCommonInfo.h"
#import "VPUPSHAUtil.h"
#import "VPLuaDownloader.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

//#import "VPMGoodsCartManager.h"//TODO IN MALL

#import "VPUPHTTPBusinessAPI.h"

#import "VPUPRandomUtil.h"
#import "VPUPJsonUtil.h"

#import <VPLuaViewSDK/LuaViewCore.h>

#import "VPLuaTrackApi.h"

#import "sys/utsname.h"

#import "VPLuaVideoPlayerSize.h"
#import "VPUPInterfaceDataServiceManager.h"

#import "VPLuaMacroDefine.h"
#import "VPLuaSDK.h"
#import "VPUPUrlUtil.h"
#import "VPUPTrafficStatistics.h"
#import "VPUPPrefetchImageManager.h"

#define IS_IOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)

NSString *const VPLuaScreenChangeNotification = @"VPLuaScreenChangeNotification";
NSString *const VPLuaNotifyUserLoginedNotification = @"VPLuaNotifyUserLoginedNotification";
NSString *const VPLuaRequireLoginNotification = @"VPLuaRequireLoginNotification";
NSString *const VPLuaActionNotification = @"VPLuaActionNotification";

static NSMutableDictionary* httpAPICache() {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *_httpAPICache;
    dispatch_once(&onceToken, ^{
        _httpAPICache = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return _httpAPICache;
}

@interface VPLuaNativeBridge()

@end

@implementation VPLuaNativeBridge

+ (VPLuaBaseNode *)luaNodeFromLuaState:(lua_State *)l {
    LuaViewCore* lv_luaviewCore = LV_LUASTATE_VIEW(l);
    VPLuaBaseNode *luaNode = (id)lv_luaviewCore.viewController;
    return luaNode;
}

+ (NSInteger)getVideoHeight:(lua_State *)l {
    VPLuaBaseNode *luaNode = [VPLuaNativeBridge luaNodeFromLuaState:l];
    float height = 0;
    VPUPVideoPlayerSize *videoPlayerSize = [VPUPInterfaceDataServiceManager videoPlayerSize];
    if (luaNode.luaController.isPortrait) {
        if (luaNode.luaController.isFullScreen) {
            height = videoPlayerSize.portraitFullScreenHeight;
        }
        else
        {
            height = videoPlayerSize.portraitSmallScreenHeight;
        }
    }
    else
    {
        height = videoPlayerSize.portraitFullScreenWidth;
    }
    return height;
}

+ (NSInteger)getVideoWidth:(lua_State *)l {
    VPLuaBaseNode *luaNode = [VPLuaNativeBridge luaNodeFromLuaState:l];
    float width = 0;
    VPUPVideoPlayerSize *videoPlayerSize = [VPUPInterfaceDataServiceManager videoPlayerSize];
    if (luaNode.luaController.isPortrait) {
        width = videoPlayerSize.portraitFullScreenWidth;
    }
    else
    {
        width = videoPlayerSize.portraitFullScreenHeight;
    }
    return width;
}

+ (void)sendAction:(NSString*)action data:(id)data luaState:(lua_State *)l {
    VPLuaBaseNode *luaNode = [VPLuaNativeBridge luaNodeFromLuaState:l];
    [VPUPActionManager pushAction:action data:data sender:luaNode.luaController];
}

+ (NSString *)cacheDataFilePath:(lua_State *)l {
    NSString *path = [self luaNodeFromLuaState:l].lvCore.bundle.currentPath;
    if ([path rangeOfString:@".bundle"].location != NSNotFound) {
        // 使用bundle加载lua,需要另外新建plist地址
        path = [[VPUPPathUtil luaPath] stringByAppendingPathComponent:@"enjoy/cacheData.plist"];
    }
    else {
        path = [path stringByAppendingPathComponent:@"cacheData.plist"];
    }
    return path;
}

+ (void)createCacheDataFile:(lua_State *)l {
    NSString *path = [self cacheDataFilePath:l];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
}

+ (NSDictionary *)getCacheData:(lua_State *)l {
    NSString *path = [self cacheDataFilePath:l];
    [self createCacheDataFile:l];
    NSDictionary *cacheData = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cacheData;
}

+ (BOOL)saveCacheData:(NSString *)key value:(NSString *)value luaState:(lua_State *)l {
    NSString *path = [self cacheDataFilePath:l];
    
    if(!key) {
        return NO;
    }
    
    NSMutableDictionary *changeData = [[NSMutableDictionary alloc] initWithDictionary:[self getCacheData:l]];
    if (value) {
        [changeData setObject:value forKey:key];
    } else {
        [changeData removeObjectForKey:key];
    }
    BOOL success = [changeData writeToFile:path atomically:YES];
    
    return success;
}

+ (BOOL)saveAllCacheData:(NSDictionary *)dictionary luaState:(lua_State *)l {
    NSString *path = [self cacheDataFilePath:l];
    if(!dictionary) {
        return NO;
    }
    
    BOOL success = [dictionary writeToFile:path atomically:YES];
    return success;
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

+(int) lvClassDefine:(lua_State *)L globalName:(NSString*) globalName{
//    [LVUtil reg:L clas:self cfunc:lvNewNativeBridge globalName:globalName defaultName:@"Native"];
    const struct luaL_Reg staticFunctions [] = {
        {"stringDrawLength",   getStringDrawLength},
        {"getVideoSize",   getVideoSize},
        {"getVideoFrame",   getVideoFrame},
        {"isPortraitScreen", isPortraitScreen},
        {"isFullScreen", isFullScreen},
        {"sendAction", sendAction},
        {"post", post},
        {"get", get},
        {"put", put},
        {"delete", delete},
        {"abort", cancel},
        {"abortAll", cancelAll},
        {"md5", md5},
        {"aesEncrypt", aesEncrypt},
        {"aesDecrypt", aesDecrypt},
        {"encode", encode},
        {"decode", decode},
        {"base64Encode", base64Encode},
        {"base64Decode", base64Decode},
        {"zipString", zipString},
        {"unzipString", unzipString},
        {"sdkVersion",sdkVersion},
        {"isDebug", isDebug},
        {"getVideoPosition", getVideoPosition},
        {"deviceBuildVersion", deviceBuildVersion},
        {"packageName", packageName},
        {"appKey", appKey},
        {"appSecret", appSecret},
        {"nativeVideoID", nativeVideoID},
        {"platformID", platformID},
        {"destroyView", destroyView},
        
        {"updateLocalLuaFile", updateLocalLuaFile},
        
//        {"addCart", addCart},
//        {"updateCartData", updateCartData},
//        {"getAllCartData", getAllCartData},
        
        {"getUserInfo", getUserInfo},
        {"setUserInfo", setUserInfo},
        
        {"getIdentity", getIdentity},
        {"getSSID", getSSID},
        
        {"trackApi", trackApi},

        {"upload",upload},
        
        {"getCacheData", getCacheData},
        {"saveCacheData", saveCacheData},
        {"getFuzzyCacheData", getFuzzyCacheData},
        {"deleteBatchCacheData", deleteBatchCacheData},
        
        {"changeToPortrait", changeToPortrait},
        
        {"iPhoneX", iPhoneX},
        
        {"tableToJson", tableToJson},
        {"jsonToTable", jsonToTable},
        
        {"report", report},
        {"unZipFile", unZipFile},
        {"getPlatformId", getPlatformId},
        {"getVideoId", getVideoId},
        {"getVideoCategory", getVideoCategory},
        {"getConfigExtendJSONString", getConfigExtendJSONString},
        {"setDebug", setDebug},
        {"screenChanged", screenChanged},
        {"widgetEvent", widgetEvent},
        {"widgetNotify", widgetNotify},
        {"requireLogin", requireLogin},
        {"notifyUserLogined", notifyUserLogined},
        {"hideKeyboard", hideKeyboard},
        {"titleBarHeight", titleBarHeight},
        {"isTitleBarShow", isTitleBarShow},
        {"currentDirection", currentDirection},
        {"stringSizeWithWidth", stringSizeWithWidth},// for iOS
        {"safeAreaInsets",safeAreaInsets},// for iOS
        {"phoneType", phoneType},
        {"phoneCarrier", phoneCarrier},
        {"rsaEncryptStringWithPublicKey", rsaEncryptStringWithPublicKey},
        {"rsaDecryptStringWithPublicKey", rsaDecryptStringWithPublicKey},
        {"commonParam", commonParam},
        {"osType",osType},
        {"sha1",sha1},
        {"px2Dpi",px2Dpi},
        {"preloadImage", preloadImage},
        {"preloadVideo", preloadVideo},
        {"preloadLuaList", preloadLuaList},
        {"copyStringToPasteBoard", copyStringToPasteBoard},
        {"videoOShost", videoOShost},
        {"isCacheVideo", isCacheVideo},
        {"currentVideoTime", currentVideoTime},
        {"videoDuration", videoDuration},
//        {"holderSize", getHolderSize},
        {NULL, NULL}
    };
    lv_createClassMetaTable(L,META_TABLE_NativeObject);
    luaL_openlib(L, "Native", staticFunctions, 0);
    return 1;
}

#pragma mark - C function

static int md5(lua_State *L) {
    
    if( lua_gettop(L) >= 2 ) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            if (string) {
                NSString *result = [VPUPMD5Util md5HashString:string];
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int aesEncrypt(lua_State *L) {
    if( lua_gettop(L) >= 4) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *key = lv_paramString(L, 3);
            NSString *iv = lv_paramString(L, 4);
            if (string) {
                NSString *result = [VPUPAESUtil aesEncryptString:string key:key initVector:iv];
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int aesDecrypt(lua_State *L) {
    if( lua_gettop(L) >= 4) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *key = lv_paramString(L, 3);
            NSString *iv = lv_paramString(L, 4);
            if (string) {
                NSString *result = [VPUPAESUtil aesDecryptString:string key:key initVector:iv];
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int encode(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = [lv_paramString(L, 2) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            if (string) {
                lua_pushstring(L, [string UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int decode(lua_State *L) {
    
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = [lv_paramString(L, 2) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            if (string) {
                lua_pushstring(L, [string UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int zipString(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *result = VPUP_GZIPCompressBase64String(string);
            if (string) {
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int unzipString(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *result = VPUP_GZIPUncompressBase64StringToString(string);
            if (string) {
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int deviceBuildVersion(lua_State *L) {
    lua_pushstring(L, [VPUPGeneralInfo appDeviceSystemVersion].UTF8String);
    return 1;
}

static int packageName(lua_State *L) {
    lua_pushstring(L, [VPUPGeneralInfo appBundleID].UTF8String);
    return 1;
}

static int sdkVersion(lua_State *L) {
    lua_pushstring(L, [VideoPlsUtilsPlatformSDKVersion UTF8String]);
    return 1;
}

static int appKey(lua_State *L) {
    lua_pushstring(L, [VPLuaSDK sharedSDK].appKey.UTF8String);
    return 1;
}

static int appSecret(lua_State *L) {
    lua_pushstring(L, [VPLuaSDK sharedSDK].appSecret.UTF8String);
    return 1;
}

static int platformID(lua_State *L) {
    NSString *platformId = [VPLuaSDK sharedSDK].videoInfo.platformID;
    if(!platformId) {
        platformId = @"";
    }
    lua_pushstring(L, platformId.UTF8String);
    return 1;
}

static int nativeVideoID(lua_State *L) {
    NSString *nativeVideoID = [VPLuaSDK sharedSDK].videoInfo.nativeID;
    if(!nativeVideoID) {
        nativeVideoID = @"";
    }
    lua_pushstring(L, nativeVideoID.UTF8String);
    return 1;
}

static int getPlatformId(lua_State *L) {
    NSString *platformId = [VPLuaSDK sharedSDK].videoInfo.platformID;
    if(!platformId) {
        platformId = @"";
    }
    lua_pushstring(L, platformId.UTF8String);
    return 1;
}

static int getVideoId(lua_State *L) {
    NSString *videoId = [VPLuaSDK sharedSDK].videoInfo.nativeID;
    if(!videoId) {
        videoId = @"";
    }
    lua_pushstring(L, videoId.UTF8String);
    return 1;
}

static int isDebug(lua_State *L) {
    lua_pushnumber(L, [[VPUPDebugSwitch sharedDebugSwitch] debugState]);
    return 1;
}

static int base64Encode(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *result = [VPUPBase64Util base64EncryptionString:string];
            if (string) {
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int base64Decode(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *string = lv_paramString(L, 2);
            NSString *result = [VPUPBase64Util base64DecryptionString:string];
            if (string) {
                lua_pushstring(L, [result UTF8String]);
                return 1;
            }
        }
    }
    return 0;

}


static int getStringDrawLength(lua_State *L) {
    
    if( lua_gettop(L)>=2 ) {
        if (lua_isstring(L, 2) && lua_isnumber(L, 3)) {
            NSString *string = lv_paramString(L, 2);
            CGFloat fontSize = lua_tonumber(L, 3);
            NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
            attrDict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize * VPUPFontScale];
            CGSize cgSize = [string sizeWithAttributes:attrDict];
            lua_pushnumber(L, cgSize.width);
            return 1;
        }
    }
    return 0;
}

static int getVideoSize(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        int type = (int)lua_tonumber(L, 2);
        float w,h,originY;
        VPUPVideoPlayerSize *videoPlayerSize = [VPUPInterfaceDataServiceManager videoPlayerSize];
        switch (type) {
            case 0:
                w = videoPlayerSize.portraitFullScreenWidth;
                h = videoPlayerSize.portraitSmallScreenHeight;
                originY = videoPlayerSize.portraitSmallScreenOriginY;
                break;
            case 1:
                w = videoPlayerSize.portraitFullScreenWidth;
                h = videoPlayerSize.portraitFullScreenHeight;
                originY = 0;
                break;
            case 2:
                w = videoPlayerSize.portraitFullScreenHeight;
                h = videoPlayerSize.portraitFullScreenWidth;
                originY = 0;
                break;
                
            default:
                w = [VPLuaNativeBridge getVideoWidth:L];
                h = [VPLuaNativeBridge getVideoHeight:L];
                originY = 0;
                break;
        }
        lua_pushnumber(L, w);
        lua_pushnumber(L, h);
        lua_pushnumber(L, originY);
    }
    else
    {
        lua_pushnumber(L, [VPLuaNativeBridge getVideoWidth:L]);
        lua_pushnumber(L, [VPLuaNativeBridge getVideoHeight:L]);
        lua_pushnumber(L, 0);
    }
    return 3;
}

static int getVideoFrame(lua_State *L) {
    CGRect videoFrame = [VPUPInterfaceDataServiceManager videoFrame];
    lua_pushnumber(L, videoFrame.origin.x);
    lua_pushnumber(L, videoFrame.origin.y);
    lua_pushnumber(L, videoFrame.size.width);
    lua_pushnumber(L, videoFrame.size.height);
    return 4;
}

static int getVideoPosition(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaNativeBridge luaNodeFromLuaState:L];
    lua_pushnumber(L, luaNade.luaController.rootView.bounds.origin.x);
    lua_pushnumber(L, luaNade.luaController.rootView.bounds.origin.y);
    return 2;
}

static int isPortraitScreen(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaNativeBridge luaNodeFromLuaState:L];
    lua_pushboolean(L, luaNade.luaController.isPortrait);
    return 1;
}

static int isFullScreen(lua_State *L) {
    VPLuaBaseNode *luaNade = [VPLuaNativeBridge luaNodeFromLuaState:L];
    lua_pushboolean(L, luaNade.luaController.isFullScreen);
    return 1;
}

static int sendAction(lua_State *L) {
    if (lua_isstring(L, 2)) {
        NSString *string = lv_paramString(L, 2);
        
        id dict = nil;
        if(lua_gettop(L) >= 3) {
            if(lua_isstring(L, 3)) {
                dict = lv_paramString(L, 3);
            }
            else if( lua_type(L, 3) == LUA_TTABLE ) {
                dict = lv_luaValueToNativeObject(L, 3);
            }
        }
        
        [VPLuaNativeBridge sendAction:string data:dict luaState:L];
    }
    return 0;
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
    if(lua_gettop(L) >= 2) {
        NSString *apiId = [NSString stringWithFormat:@"%ld",(NSUInteger)lua_tointeger(L, 2)];
        VPUPHTTPBusinessAPI *api = [httpAPICache() objectForKey:apiId];
        if (api) {
            [httpAPICache() removeObjectForKey:apiId];
            NSDictionary *cacheData = [VPLuaNativeBridge getCacheData:L];
            if([cacheData objectForKey:apiId]) {
                NSString *value = [cacheData objectForKey:apiId];
                [LVUtil unregistry:L key:value];
            }
            [[VPLuaNetworkManager Manager].httpManager cancelAPIRequest:api];
        }
    }
    return 0;
}

static int cancelAll(lua_State *L) {
    [[VPLuaNetworkManager Manager].httpManager cancelAll];
    return 0;
}

static int httpRequest(lua_State *L, VPUPRequestMethodType methodType) {
    
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
//        __weak typeof(cell) weakCell = cell;
//        NSLog(@"apirequestnative=====%@%@===%@", api.baseUrl, api.requestMethod, VPUP_DictionaryToJson(data));
        NSString *apiId = [NSString stringWithFormat:@"%ld",api.apiId];
        api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
            //没有回调，网络请求不处理回调
            if (!needToCallBack) {
                return;
            }
            if ([httpAPICache() objectForKey:apiId]) {
                [httpAPICache() removeObjectForKey:apiId];
            }
            //request 已经cancel
            else {
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
//            [weakCell apiComplete:responseObject error:error response:response requestMethod:bRequestMethod];
        };
        [httpAPICache() setObject:api forKey:apiId];
        [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
        lua_pushinteger(L, api.apiId);
        [VPLuaNativeBridge saveCacheData:[NSString stringWithFormat:@"%ld",api.apiId] value:bRequestMethod luaState:L];
        return 1;
    }
    return 0;
}

static int upload(lua_State *L) {
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
        
        //重组function的key,保证不重复
        __block NSString *bRequestMethod = [[VPUPMD5Util md5_16bitHashString:[NSString stringWithFormat:@"%@%@", requestUrl, filepath]] stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
        [LVUtil registryValue:L key:bRequestMethod stack:4];
        
        VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
        api.customRequestUrl = requestUrl;
        api.apiRequestMethodType = VPUPRequestMethodTypePOST;
        api.apiRequestConstructingBodyBlock = ^(id<VPUPMultipartFormData> _Nonnull formData) {
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
            NSString *fileType = [VPLuaNativeBridge contentTypeForImageData:data];
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
        
        [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
        
    }
    return 0;
}

static int updateLocalLuaFile(lua_State *L) {
    if( lua_gettop(L) >= 3) {
        NSString *lua = nil;
        NSString *lua_md5 = nil;
        if (lua_isstring(L, 2)) {
            lua = lv_paramString(L, 2);
        }
        if (lua_isstring(L, 3)) {
            lua_md5 = lv_paramString(L, 3);
        }
        
        if(lua && lua_md5) {
            [VPLuaNodeController saveLuaFileWithUrl:lua md5:lua_md5];
        }
    }
    return 0;
}

static int getUserInfo(lua_State *L) {
    NSDictionary *userInfoDict = [VPUPInterfaceDataServiceManager getUserInfo];
    if(userInfoDict) {
        lv_pushNativeObject(L, userInfoDict);
        return 1;
    }
    return 0;
}

static int setUserInfo(lua_State *L) {
    LVUserDataInfo * user = (LVUserDataInfo *)lua_touserdata(L, 1);
    if( user ){
        //maybe only trigger in portrait webview
//        VPLuaNativeBridge* native = (__bridge VPLuaNativeBridge *)(user->object);
        
        // push Notification ?
        
    }
    return 0;
}

static int getIdentity(lua_State *L) {
    lua_pushstring(L, [VPUPGeneralInfo userIdentity].UTF8String);
    return 1;
}

static int getSSID(lua_State *L) {
    NSString *ssid = [VPLuaSDK sharedSDK].videoInfo.ssid;
    if(!ssid) {
        ssid = @"";
    }
    lua_pushstring(L, ssid.UTF8String);
    return 1;
}

static int destroyView(lua_State *L) {
    if(lua_gettop(L) >= 2) {
        NSString *nodeId = lv_paramString(L, 2);
        [VPLuaNativeBridge sendAction:VPUP_SchemeAddPath(nodeId,@"turnOff") data:@{@"id":nodeId} luaState:L];
    }
    else {
        VPLuaBaseNode *luaNode = [VPLuaNativeBridge luaNodeFromLuaState:L];
        [luaNode destroyView];
    }
    return 0;
}

static int trackApi(lua_State *L) {
    int argN = lua_gettop(L);
    if(argN >= 2) {
        NSUInteger cat = 0;
        NSMutableDictionary* data = nil;
        
        if(lua_isnumber(L, 2)) {
            cat = (NSUInteger)lua_tonumber(L, 2);
        }
        
        if(lua_type(L, 3) == LUA_TTABLE) {
            data = lv_luaTableToDictionary(L, 3);
            data = [data mutableCopy];
        }
        
        VPLuaTrackApi *api = [[VPLuaTrackApi alloc] initWithTrackEventCat:cat params:data];
        
        [[VPLuaNetworkManager Manager].httpManager sendAPIRequest:api];
        
    }
    return 0;
}

static int getCacheData(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *key = lv_paramString(L, 2);
            if(key) {
                NSDictionary *cacheData = [VPLuaNativeBridge getCacheData:L];
                if([cacheData objectForKey:key]) {
                    NSString *value = [cacheData objectForKey:key];
                    lua_pushstring(L, [value UTF8String]);
                    return 1;
                }
            }
        }
    }
    return 0;
}

static int saveCacheData(lua_State *L) {
    int argN = lua_gettop(L);
    if(argN >= 3) {
        NSString *key = nil;
        NSString *value = nil;
        
        if(lua_isstring(L, 2)) {
            key = lv_paramString(L, 2);
        }
        if(lua_isstring(L, 3)) {
            value = lv_paramString(L, 3);
        }
        
        BOOL success = [VPLuaNativeBridge saveCacheData:key value:value luaState:L];
        
        lua_pushboolean(L, success);
        return 1;
    }
    return 0;
}

static int getFuzzyCacheData(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *fuzzyKey = lv_paramString(L, 2);
            if(fuzzyKey) {
                NSDictionary *cacheData = [VPLuaNativeBridge getCacheData:L];
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                for (NSString *key in cacheData.allKeys) {
                    if ([key containsString:fuzzyKey]) {
                        [data setObject:[cacheData objectForKey:key] forKey:key];
                    }
                }
                
                if (data && [data.allKeys count] > 0) {
                    lv_pushNativeObject(L, data);
                    return 1;
                }
            }
        }
    }
    return 0;
}

static int deleteBatchCacheData(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_type(L, 2) == LUA_TTABLE) {
            NSArray *keys = lv_luaValueToNativeObject(L, 2);
            if ([keys isKindOfClass:[NSArray class]] && [keys count] > 0) {
                
                NSMutableDictionary *changeData = [[NSMutableDictionary alloc] initWithDictionary:[VPLuaNativeBridge getCacheData:L]];
                
                BOOL hasChanged = NO;
                for (NSString *key in keys) {
                    if ([changeData objectForKey:key]) {
                        [changeData removeObjectForKey:key];
                        hasChanged = YES;
                    }
                }
                
                if (hasChanged) {
                    [VPLuaNativeBridge saveAllCacheData:changeData luaState:L];
                }
            }
        }
    }
    return 0;
}

static int changeToPortrait(lua_State *L) {
    if( lua_gettop(L) >= 2 && lua_type(L, 2) == LUA_TBOOLEAN) {
        NSDictionary *dict = nil;
        BOOL toPortrait = lua_toboolean(L, 2);
        dict = @{@"portrait":@(toPortrait)};
        [VPLuaNativeBridge sendAction:VPUP_SchemeAddPath(@"toPortrait", @"device") data:dict luaState:L];
    }
    return 0;
}

static int iPhoneX(lua_State *L) {
    lua_pushboolean(L, [VPUPDeviceUtil isIPhoneX]);
    return 1;
}

static int tableToJson(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_type(L, 2) == LUA_TTABLE) {
            NSDictionary *data = lv_luaTableToDictionary(L, 2);
            NSString *json = VPUP_DictionaryToJson(data);
            
            if (json) {
                lua_pushstring(L, [json UTF8String]);
                return 1;
            }
        }
    }
    return 0;
}

static int jsonToTable(lua_State *L) {
    if( lua_gettop(L) >= 2) {
        if (lua_isstring(L, 2)) {
            NSString *json = lv_paramString(L, 2);
            NSDictionary *dictionary = VPUP_JsonToDictionary(json);
            if (dictionary) {
                lv_pushNativeObject(L, dictionary);
                return 1;
            }
        }
    }
    return 0;
}

static int report(lua_State *L) {
    return 0;
}

static int unZipFile(lua_State *L) {
    if( lua_gettop(L) >= 3) {
        if (lua_isstring(L, 2)&&lua_isstring(L, 3)) {
            NSString *zipFilePath = lv_paramString(L, 2);
            NSString *filePath = lv_paramString(L,3);
            
            LVZipArchive *archive = [LVZipArchive archiveWithData:[NSData dataWithContentsOfFile:zipFilePath]];
            if ([archive unzipToDirectory:filePath]) {
                lua_pushnumber(L, archive.data.length);
                return 1;
            }
            else {
                lua_pushnumber(L, -1);
                return 1;
            }
        }
    }
    return 0;
}

static int getVideoCategory(lua_State *L) {
    NSString *category = [VPLuaSDK sharedSDK].videoInfo.category;
    if(!category) {
        category = @"";
    }
    lua_pushstring(L, category.UTF8String);
    return 1;
}

static int getConfigExtendJSONString(lua_State *L) {
    NSString *extendJSONString = [VPLuaSDK sharedSDK].videoInfo.extendJSONString;
    if(!extendJSONString) {
        extendJSONString = @"";
    }
    lua_pushstring(L, extendJSONString.UTF8String);
    return 1;
}

static int setDebug(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        NSInteger type = lua_tointeger(L, 2);
        VPUPDebugState state = VPUPDebugStateOnline;
        switch (type) {
            case 0:
                state = VPUPDebugStateDevelop;
                break;
            case 1:
                state = VPUPDebugStateTest;
                break;
            case 2:
                state = VPUPDebugStateProduction;
                break;
            case 3:
                state = VPUPDebugStateOnline;
                break;
                
            default:
                state = VPUPDebugStateOnline;
                break;
        }
        [[VPUPDebugSwitch sharedDebugSwitch] switchEnvironment:type];
    }
    return 0;
}

static int screenChanged(lua_State *L) {
    if(lua_gettop(L) >= 2) {
        NSInteger screenType = lua_tointeger(L, 2);
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[NSString stringWithFormat:@"%ld",screenType] forKey:@"orientation"];
        if (lua_gettop(L) >= 3 && lua_isstring(L, 3)) {
            NSString *url = lv_paramString(L, 3);
            [dict setObject:url forKey:@"url"];
        }
        if (lua_gettop(L) >= 4 && lua_isstring(L, 4)) {
            NSString *ssid = lv_paramString(L, 4);
            [dict setObject:ssid forKey:@"ssid"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaScreenChangeNotification object:nil userInfo:dict];
    }
    return 0;
}

static int widgetEvent(lua_State *L) {
    //两个必选参数，其他为可选参数
    if (lua_gettop(L) >= 3) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:6];
        
        if (lua_isnumber(L, 2)) {
            NSInteger eventType = lua_tointeger(L, 2);
            [dict setObject:@(eventType) forKey:@"eventType"];
        }
        if (lua_isstring(L, 3)) {
            NSString *adId = lv_paramString(L, 3);
            [dict setObject:adId forKey:@"adID"];
        }
        
        if (lua_gettop(L) >= 4 && lua_isstring(L, 4)) {
            NSString *resourceId = lv_paramString(L, 4);
            [dict setObject:resourceId forKey:@"adName"];
        }
        
        if (lua_gettop(L) >= 5 && lua_isnumber(L, 5)) {
            NSInteger idType = lua_tointeger(L, 5);
            [dict setObject:@(idType) forKey:@"actionType"];
        }
        
        if (lua_gettop(L) >= 6 && lua_isstring(L, 6)) {
            NSString *url = lv_paramString(L, 6);
            [dict setObject:url forKey:@"actionString"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaActionNotification object:nil userInfo:dict];
    }
    return 0;
}

static int widgetNotify(lua_State *L) {
    
    if (lua_type(L, 2) == LUA_TTABLE) {
        NSDictionary *dic = lv_luaTableToDictionary(L,2);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaActionNotification object:nil userInfo:dic];
    }
    return 0;
}

static int titleBarHeight(lua_State *L) {
    lua_pushnumber(L, [VPUPDeviceUtil statusBarHeight]);
    return 1;
}

static int isTitleBarShow(lua_State *L) {
    lua_pushboolean(L, ![UIApplication sharedApplication].isStatusBarHidden);
    return 1;
}

static int requireLogin(lua_State *L) {
    if (lua_gettop(L) >= 2 && lua_isfunction(L, 2)) {
        
        //重组function的key,保证不重复
        __block NSString *bRequireLoginMethod = [@"requireLogin" stringByAppendingString:[VPUPRandomUtil randomStringByLength:3]];
        
        [LVUtil registryValue:L key:bRequireLoginMethod stack:2];
        
        void(^completeBlock)(NSDictionary *) = ^(NSDictionary *userInfo) {
                lua_checkstack32(L);
                lv_pushNativeObject(L, userInfo);
                [LVUtil call:L lightUserData:bRequireLoginMethod key1:"callback" key2:NULL nargs:1];
                [LVUtil unregistry:L key:bRequireLoginMethod];
        };
        NSDictionary *completeDict = @{@"completeBlock" : completeBlock};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaRequireLoginNotification object:nil userInfo:completeDict];
    }
    return 0;
}

static int notifyUserLogined(lua_State *L) {
    if (lua_gettop(L) >= 2 && lua_istable(L, 2)) {
        NSDictionary *userInfo = lv_luaValueToNativeObject(L, 2);
        [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaNotifyUserLoginedNotification object:nil userInfo:userInfo];
    }
    return 0;
}

static int hideKeyboard(lua_State *L) {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    return 0;
}

static int currentDirection(lua_State *L) {
    VPLuaBaseNode *luaNode = [VPLuaNativeBridge luaNodeFromLuaState:L];
    lua_pushnumber(L, luaNode.luaController.currentOrientation);
    return 1;
}

static int stringSizeWithWidth(lua_State *L) {
    if (lua_gettop(L) >= 4) {
        NSString *text = lv_paramString(L, 2);
        CGFloat width = lua_tonumber(L, 3);
        CGFloat fontSize = lua_tonumber(L, 4);
        
        if (!text || text.length == 0) {
            lua_pushnumber(L, width + 1);
            lua_pushnumber(L, fontSize + 1);
            return 2;
        }
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentLeft;
        
        NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize * VPUPFontScale], NSParagraphStyleAttributeName:style}];
        
        CGSize size =  [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        lua_pushnumber(L, ceil(size.width) + 1);
        lua_pushnumber(L, ceil(size.height) + 1);
        return 2;
    }
    return 0;
}

static int safeAreaInsets(lua_State *L) {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
    lua_pushnumber(L, insets.top);
    lua_pushnumber(L, insets.left);
    lua_pushnumber(L, insets.bottom);
    lua_pushnumber(L, insets.right);
    return 4;
}

static int phoneType(lua_State *L) {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    lua_pushstring(L, [platform UTF8String]);
    return 1;
}

static int phoneCarrier(lua_State *L) {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        mobile = @"无运营商";
    }else{
        mobile = [carrier carrierName];
    }
    lua_pushstring(L, [mobile UTF8String]);
    return 1;
}

static int rsaEncryptStringWithPublicKey(lua_State *L) {
    if (lua_gettop(L) >= 3) {
        NSString *string = lv_paramString(L, 2);
        NSString *publicKey = lv_paramString(L, 3);
        NSString *encryptString = [VPUPRSAUtil encryptString:string publicKey:publicKey];
        lua_pushstring(L, [encryptString UTF8String]);
        return 1;
    }
    return 0;
}

static int rsaDecryptStringWithPublicKey(lua_State *L) {
    if (lua_gettop(L) >= 3) {
        NSString *string = lv_paramString(L, 2);
        NSString *publicKey = lv_paramString(L, 3);
        NSString *decryptString = [VPUPRSAUtil decryptString:string publicKey:publicKey];
        lua_pushstring(L, [decryptString UTF8String]);
        return 1;
    }
    return 0;
}

static int commonParam(lua_State *L) {
//    NSString *commonParamString = VPUP_DictionaryToJson([VPUPCommonInfo commonParam]);
//    lua_pushstring(L, [commonParamString UTF8String]);
    lv_pushNativeObject(L, [VPUPCommonInfo commonParam]);
    return 1;
}

static int osType(lua_State *L) {
    lua_pushnumber(L, [VPLuaSDK sharedSDK].type);
    return 1;
}

static int sha1(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        NSString *string = lv_paramString(L, 2);
        NSString *sha1String = [VPUPSHAUtil sha1HashString:string];
        lua_pushstring(L, [sha1String UTF8String]);
        return 1;
    }
    return 0;
}

static int px2Dpi(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        float px = lua_tonumber(L, 2);
        lua_pushnumber(L, px / [UIScreen mainScreen].scale);
        return 1;
    }
    return 0;
}

static int preloadImage(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        if( lua_type(L, 2) == LUA_TTABLE ) {
            NSArray *array = lv_luaValueToNativeObject(L, 2);
            if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
                
                VPUPPrefetchImageManager *prefetchImageManager = [[VPUPPrefetchImageManager alloc] initWithImageManager:[VPLuaNetworkManager Manager].imageManager];
                
                [prefetchImageManager prefetchURLs:array complete:^(VPUPTrafficStatisticsList *trafficList) {
                    
                    if (trafficList) {
                        [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeOpenVideo];
                    }
                }];
            }
        }
    }
    return 0;
}

static int preloadVideo(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        if( lua_type(L, 2) == LUA_TTABLE ) {
            NSArray *array = lv_luaValueToNativeObject(L, 2);
            if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
                [[VPLuaNetworkManager Manager].videoManager prefetchURLs:array complete:^(VPUPTrafficStatisticsList *trafficList) {
                    
                    if (trafficList) {
                        [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeOpenVideo];
                    }
                    
                }];
            }
        }
    }
    return 0;
}

static int preloadLuaList(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        if( lua_type(L, 2) == LUA_TTABLE ) {
            NSArray *array = lv_luaValueToNativeObject(L, 2);
            if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
                
                //根据md5,先去一波重
                NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *dict in array) {
                    
                    if (![dict objectForKey:@"md5"] || [[dict objectForKey:@"md5"] isEqualToString:@""]) {
                        continue;
                    }
                    
                    BOOL needAdd = YES;
                    for (NSDictionary *noRepDict in newArray) {
                        NSString *md5 = [dict objectForKey:@"md5"];
                        NSString *noRepMd5 = [noRepDict objectForKey:@"md5"];
                        if ([md5 isEqualToString:noRepMd5]) {
                            needAdd = NO;
                            break;
                        }
                    }
                    
                    if (needAdd) {
                        [newArray addObject:dict];
                    }
                }
                
                [[VPLuaDownloader sharedDownloader] checkAndDownloadFilesList:newArray complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
                    
                    if (trafficList) {
                        [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeOpenVideo];
                    }
                    
                    NSLog(@"preloadLuaList error %@", error);
                }];
            }
        }
    }
    return 0;
}

static int copyStringToPasteBoard(lua_State *L) {
    if (lua_gettop(L) >= 2) {
        if( lua_type(L, 2) == LUA_TSTRING ) {
            NSString *string = lv_paramString(L, 2);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = string;
        }
    }
    return 0;
}

static int videoOShost(lua_State *L) {
    lua_pushstring(L, [VPLuaServerHost UTF8String]);
    return 1;
}

static int isCacheVideo(lua_State *L) {
    BOOL fileExists = NO;
    if( lua_gettop(L) >= 2) {
        if (lua_type(L, 2) == LUA_TSTRING) {
            NSString *urlString = lv_paramString(L, 2);
            
//            NSURL *url = [NSURL URLWithString:[VPUPUrlUtil urlencode:urlString]];
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSString *fileName = [NSString stringWithFormat:@"%@.%@",[VPUPMD5Util md5HashString:url.absoluteString],[url pathExtension]];
                
                NSString *destinationPath = [VPUPPathUtil pathByPlaceholder:@"videoAds"];
                
                NSString *videoPath = [NSString stringWithFormat:@"%@/%@", destinationPath, fileName];
                
                fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
            }
        }
    }
    lua_pushboolean(L, fileExists);
    return 1;
}

static int currentVideoTime(lua_State *L) {
    NSTimeInterval progress = [VPUPInterfaceDataServiceManager videoPlayerCurrentTime];
    lua_pushnumber(L, progress);
    return 1;
}

static int videoDuration(lua_State *L) {
    NSTimeInterval progress = [VPUPInterfaceDataServiceManager videoPlayerCurrentItemAssetDuration];
    lua_pushnumber(L, progress);
    return 1;
}

//static int getHolderSize(lua_State *L) {
//    VPLuaBaseNode *luaNade = [VPLuaNativeBridge luaNodeFromLuaState:L];
//    lua_pushnumber(L, luaNade.luaController.rootView.bounds.size.width);
//    lua_pushnumber(L, luaNade.luaController.rootView.bounds.size.height);
//    return 2;
//}

@end
