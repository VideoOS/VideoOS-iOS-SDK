//
//  VPLuaHolderRequest.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaHolderObject.h"

@protocol VPUPHTTPAPIManager;


@interface VPLuaHolderRequest : NSObject

+ (VPLuaHolderRequest *)request;

/**
 发送获取小程序
 
 @param holderID 小程序ID
 @param completeBlock 回调函数
 @return requestID
 */
- (NSString *)requestWithHolderID:(NSString *)holderID
                       apiManager:(id<VPUPHTTPAPIManager>)apiManager
                         complete:(void (^)(VPLuaHolderObject *luaObject, NSError *error))completeBlock;

- (void)trackWithHolderID:(NSString *)holderID
               apiManager:(id<VPUPHTTPAPIManager>)apiManager;

- (void)cancelRequestWithID:(NSString *)requestID;


@end

