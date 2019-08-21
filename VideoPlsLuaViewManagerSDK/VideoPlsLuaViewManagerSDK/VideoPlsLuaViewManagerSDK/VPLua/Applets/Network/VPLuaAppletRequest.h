//
//  VPLuaAppletRequest.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaAppletObject.h"

@protocol VPUPHTTPAPIManager;


@interface VPLuaAppletRequest : NSObject

+ (VPLuaAppletRequest *)request;

/**
 发送获取小程序
 
 @param appletID 小程序ID
 @param completeBlock 回调函数
 @return requestID
 */
- (NSString *)requestWithAppletID:(NSString *)appletID
                       apiManager:(id<VPUPHTTPAPIManager>)apiManager
                         complete:(void (^)(VPLuaAppletObject *luaObject, NSError *error))completeBlock;

- (void)cancelRequestWithID:(NSString *)requestID;


@end

