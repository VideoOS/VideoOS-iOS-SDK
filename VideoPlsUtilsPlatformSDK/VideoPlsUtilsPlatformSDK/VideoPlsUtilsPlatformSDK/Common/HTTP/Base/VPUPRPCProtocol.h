//
//  VPUPRPCProtocol.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPHTTPBaseAPI;

NS_ASSUME_NONNULL_BEGIN
@protocol VPUPRPCProtocol <NSObject>

/**
 *  遵循RPC协议的RequestUrl
 *
 *  @param api 用来组装RPC协议的api
 *
 *  @return 组装完成后的rpc url
 */
- (nullable NSString *)rpcRequestUrlWithAPI:(VPUPHTTPBaseAPI *)api;

/**
 *  遵循RPC协议的参数列表
 *
 *  @param api 用于组装RPC协议的api
 *
 *  @return 组装完成后的rpc parameters
 */
- (nullable id)rpcRequestParamsWithAPI:(VPUPHTTPBaseAPI *)api;

/**
 *  遵循RPC协议的解包函数
 *
 *  @param responseObject 一般为网络返回的Raw json数据
 *
 *  @return 解包后的json数据
 */
- (nullable id)rpcResponseObjReformer:(id)responseObject withAPI:(VPUPHTTPBaseAPI *)api;

/**
 *  rpc拆包后的格式化后的result
 *
 *  @param formattedResponseObj 使用rpcResponseObjReformer 解包后的数据
 *
 *  @return 格式化后的responseObj
 */
- (nullable id)rpcResultWithFormattedResponse:(id)formattedResponseObj withAPI:(VPUPHTTPBaseAPI *)api;

/**
 *  rpc 拆包后，服务器返回的错误信息
 *
 *  @param formattedResponseObj 使用rpcResponseObjReformer 解包后的数据
 *
 *  @return 格式化后的responseObj
 */
- (NSError *)rpcErrorWithFormattedResponse:(id)formattedResponseObj withAPI:(VPUPHTTPBaseAPI *)api;

@end
NS_ASSUME_NONNULL_END
