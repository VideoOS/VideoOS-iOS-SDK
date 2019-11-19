//
//  VPLuaHolderRequest.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaHolderRequest.h"
#import "VPUPRandomUtil.h"
#import "VPUPHTTPBusinessAPI.h"
#import "VPUPHTTPAPIManager.h"
#import "VPLuaSDK.h"
#import "VPUPCommonInfo.h"
#import "VPUPEncryption.h"
#import "VPUPJsonUtil.h"

static VPLuaHolderRequest *request = nil;

@interface VPLuaHolderRequest()

@property (atomic, strong) NSMutableDictionary *requestHolder;

@end

@implementation VPLuaHolderRequest

+ (VPLuaHolderRequest *)request {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[self alloc] init];
        request.requestHolder = [NSMutableDictionary dictionary];
    });
    return request;
}

- (NSString *)requestWithHolderID:(NSString *)holderID
                       apiManager:(id<VPUPHTTPAPIManager>)apiManager
                         complete:(void (^)(VPLuaHolderObject *luaObject, NSError *error))completeBlock {
    
    NSString *requestID = [VPUPRandomUtil randomStringByLength:6];
    
    [_requestHolder setObject:completeBlock forKey:requestID];
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"vision/getMiniAppConf"];
    //mock
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:holderID forKey:@"miniAppId"];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    
    NSString *commonParamString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
        if (!weakSelf) {
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (![strongSelf.requestHolder objectForKey:requestID]) {
            return;
        }
        
        void (^complete)(VPLuaHolderObject *luaObject, NSError *error) = [strongSelf.requestHolder objectForKey:requestID];
        
        if (error) {
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        
        //TODO: change encrypt
        if (!responseObject || ![responseObject objectForKey:@"encryptData"]) {
            NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaHolderRequest" code:1001 userInfo:@{@"reason":@"Response data parsing failure"}];
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        NSString *dataString = [VPUPAESUtil aesDecryptString:[responseObject objectForKey:@"encryptData"] key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret];
        NSDictionary *data = VPUP_JsonToDictionary(dataString);
        
        if (![data objectForKey:@"resCode"] || ![[data objectForKey:@"resCode"] isEqualToString:@"00"]) {
            //返回错误
            NSError *error = [[NSError alloc] initWithDomain:@"com.videopls.LuaHolderRequest" code:1002 userInfo:@{@"reason":@"Response data code failed"}];
            if ([data objectForKey:@"resMsg"] != nil) {
                error = [[NSError alloc] initWithDomain:@"com.videopls.LuaHolderRequest" code:1002 userInfo:@{@"reason":[data objectForKey:@"resMsg"]}];
            }
            complete(nil, error);
            [strongSelf removeRequestID:requestID];
            return;
        }
        
        VPLuaHolderObject *holder = [VPLuaHolderObject initWithResponseDictionary:data];
        holder.holderID = holderID;
        
        completeBlock(holder, nil);
        [strongSelf removeRequestID:requestID];
        
    };
    
    [apiManager sendAPIRequest:api];
    
    return requestID;
}

- (void)trackWithHolderID:(NSString *)holderID
               apiManager:(id<VPUPHTTPAPIManager>)apiManager {
    
    __weak typeof(self) weakSelf = self;
    VPUPHTTPBusinessAPI *api = [[VPUPHTTPBusinessAPI alloc] init];
    
    api.baseUrl = [NSString stringWithFormat:@"%@/%@", VPLuaServerHost, @"vision/addRecentMiniApp"];
    //mock
    api.apiRequestMethodType = VPUPRequestMethodTypePOST;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:holderID forKey:@"miniAppId"];
    [param setObject:[VPUPCommonInfo commonParam] forKey:@"commonParam"];
    
    NSString *commonParamString = VPUP_DictionaryToJson(param);
    api.requestParameters = @{@"data":[VPUPAESUtil aesEncryptString:commonParamString key:[VPLuaSDK sharedSDK].appSecret initVector:[VPLuaSDK sharedSDK].appSecret]};
    api.apiCompletionHandler = ^(id  _Nonnull responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response) {
        
    };
    [apiManager sendAPIRequest:api];
}

- (void)cancelRequestWithID:(NSString *)requestID {
    [self removeRequestID:requestID];
}

- (void)removeRequestID:(NSString *)requestID {
    if ([self.requestHolder objectForKey:requestID]) {
        [self.requestHolder removeObjectForKey:requestID];
    }
}

@end
