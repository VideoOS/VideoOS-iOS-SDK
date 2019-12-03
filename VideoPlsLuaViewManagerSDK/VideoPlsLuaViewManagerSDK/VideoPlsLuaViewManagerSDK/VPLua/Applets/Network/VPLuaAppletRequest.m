//
//  VPLuaAppletRequest.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaAppletRequest.h"
#import "VPUPRandomUtil.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPLuaSDK.h"
#import "VPUPCommonInfo.h"
#import "VPUPEncryption.h"
#import "VPUPJsonUtil.h"
#import "VPUPHTTPManagerFactory.h"

static VPLuaAppletRequest *request = nil;

@interface VPLuaAppletRequest()

@property (atomic, strong) NSMutableDictionary *requestApplets;
@property (nonatomic, weak) id<VPUPHTTPAPIManager> httpManager;

@end

@implementation VPLuaAppletRequest

+ (VPLuaAppletRequest *)request {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[self alloc] init];
        request.requestApplets = [NSMutableDictionary dictionary];
    });
    return request;
}

- (void)createHTTPManagerWith:(id<VPUPHTTPAPIManager>)httpManager {
    if (httpManager) {
        _httpManager = httpManager;
        return;
    }
    if (_httpManager) {
        return;
    }
    _httpManager = [VPUPHTTPManagerFactory createHTTPAPIManagerWithType:VPUPHTTPManagerTypeAFN];
}

- (NSString *)requestWithAppletID:(NSString *)appletID
                       apiManager:(id<VPUPHTTPAPIManager>)apiManager
                         complete:(void (^)(VPLuaAppletObject *luaObject, NSError *error))completeBlock {
    
    NSString *requestID = [VPUPRandomUtil randomStringByLength:6];
    
    [_requestApplets setObject:completeBlock forKey:requestID];
    
    [self createHTTPManagerWith:apiManager];
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"vision/v2/getMiniAppConf"];
    //mock
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:appletID forKey:@"miniAppId"];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    
    NSString *commonParamString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        if (!weakSelf) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (![strongSelf.requestApplets objectForKey:requestID]) {
            return;
        }
        
        void (^complete)(VPLuaAppletObject *luaObject, NSError *error) = [strongSelf.requestApplets objectForKey:requestID];
        
        if (error) {
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        
        //TODO: change encrypt
        if (!responseObject || ![responseObject objectForKey:@"encryptData"]) {
            NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaAppletRequest" code:1001 userInfo:@{@"reason":@"Response data parsing failure"}];
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        
        if (![data objectForKey:@"resCode"] || ![[data objectForKey:@"resCode"] isEqualToString:@"00"]) {
            //返回错误
            NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaAppletRequest" code:1002 userInfo:@{@"reason":@"Response data code failed"}];
            if ([data objectForKey:@"resMsg"] != nil) {
                error = [[NSError alloc] initWithDomain:@"com.videopls.LuaAppletRequest" code:1002 userInfo:@{@"reason":[data objectForKey:@"resMsg"]}];
            }
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        
        VPLuaAppletObject *applet = [VPLuaAppletObject initWithResponseDictionary:data];
//        applet.appletID = appletID;
        
        completeBlock(applet, nil);
        [strongSelf removeRequestID:requestID];
        
    };
    
    [_httpManager sendAPIRequest:api];
    
    return requestID;
}

- (void)trackWithAppletID:(NSString *)appletID
               apiManager:(id<VPUPHTTPAPIManager>)apiManager {
    
    [self createHTTPManagerWith:apiManager];
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"vision/addRecentMiniApp"];
    //mock
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:appletID forKey:@"miniAppId"];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    
    NSString *commonParamString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
    };
    [_httpManager sendAPIRequest:api];
}

- (NSString *)requestToolWithID:(NSString *)toolID
                     apiManager:(id<VPUPHTTPAPIManager>)apiManager
                       complete:(void (^)(VPMiniAppInfo *appInfo, NSError *error))completeBlock {
 
    NSString *requestID = [VPUPRandomUtil randomStringByLength:6];
    
    [_requestApplets setObject:completeBlock forKey:requestID];
    
    [self createHTTPManagerWith:apiManager];
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"api/getMiniAppInfo"];
        //mock
        api.apiRequestMethodType = VPUPRequestMethodTypePOST;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:toolID forKey:@"miniAppId"];
        [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
        
        NSString *commonParamString = VPUP_DictionaryToJson(param);
        api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
        api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
            
            if (!weakSelf) {
                return;
            }
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (![strongSelf.requestApplets objectForKey:requestID]) {
                return;
            }
            
            void (^complete)(VPLuaAppletObject *luaObject, NSError *error) = [strongSelf.requestApplets objectForKey:requestID];
            
            if (error) {
                complete(nil, error);
                [strongSelf removeRequestID:requestID];
                return;
            }
            
            //TODO: change encrypt
            if (!responseObject || ![responseObject objectForKey:@"encryptData"]) {
                NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaToolRequest" code:1001 userInfo:@{@"reason":@"Response data parsing failure"}];
                complete(nil, error);
                [strongSelf removeRequestID:requestID];
                return;
            }
            NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
            NSDictionary *data = VPUP_JsonToDictionary(dataString);
            
            if (![data objectForKey:@"resCode"] || ![[data objectForKey:@"resCode"] isEqualToString:@"00"]) {
                //返回错误
                NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaToolRequest" code:1002 userInfo:@{@"reason":@"Response data code failed"}];
                if ([data objectForKey:@"resMsg"] != nil) {
                    error = [[NSError alloc] initWithDomain:@"com.videopls.LuaToolRequest" code:1002 userInfo:@{@"reason":[data objectForKey:@"resMsg"]}];
                }
                complete(nil, error);
                [strongSelf removeRequestID:requestID];
                return;
            }
            
            VPMiniAppInfo *info = [VPMiniAppInfo initWithResponseDictionary:[data objectForKey:@"miniAppInfo"]];
            
            completeBlock(info, nil);
            [strongSelf removeRequestID:requestID];
            
        };
        
        [_httpManager sendAPIRequest:api];
        
        return requestID;
}

- (void)cancelRequestWithID:(NSString *)requestID {
    [self removeRequestID:requestID];
}

- (void)removeRequestID:(NSString *)requestID {
    if ([self.requestApplets objectForKey:requestID]) {
        [self.requestApplets removeObjectForKey:requestID];
    }
}

@end
