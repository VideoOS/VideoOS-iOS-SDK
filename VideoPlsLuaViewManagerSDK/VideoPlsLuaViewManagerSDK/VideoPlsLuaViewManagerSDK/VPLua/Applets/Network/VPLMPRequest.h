//
//  VPLMPRequest.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLMPObject.h"

@protocol VPUPHTTPAPIManager;


@interface VPLMPRequest : NSObject

+ (VPLMPRequest *)request;

/**
 发送获取小程序
 
 @param mpID 小程序ID
 @param completeBlock 回调函数
 @return requestID
 */
- (NSString *)requestWithMPID:(NSString *)mpID
                       apiManager:(id<VPUPHTTPAPIManager>)apiManager
                         complete:(void (^)(VPLMPObject *luaObject, NSError *error))completeBlock;

- (void)trackWithMPID:(NSString *)mpID
               apiManager:(id<VPUPHTTPAPIManager>)apiManager;

- (NSString *)requestToolWithID:(NSString *)toolID
                     apiManager:(id<VPUPHTTPAPIManager>)apiManager
                       complete:(void (^)(VPMiniAppInfo *appInfo, NSError *error))completeBlock;

- (void)cancelRequestWithID:(NSString *)requestID;


@end

