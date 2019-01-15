//
//  VPUPHTTPGeneralAPI.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPBaseAPI.h"


NS_ASSUME_NONNULL_BEGIN

@interface VPUPHTTPGeneralAPI : VPUPHTTPBaseAPI


/**
 *  同BaseAPI requestMethod
 */
@property (nonatomic, copy) NSString *requestMethod;

/**
 *  安全协议设置
 */
@property (nonatomic, strong) VPUPSecurityPolicy *apiSecurityPolicy;

/**
 *  同BaseAPI apiRequestMethodType
 */
@property (nonatomic, assign) VPUPRequestMethodType apiRequestMethodType;

/**
 *  同BaseAPI apiPriority
 */
@property (nonatomic, assign) VPUPHTTPAPIPriority apiPriority;

/**
 *  同BaseAPI apiRequestSerializerType
 */
@property (nonatomic, assign) VPUPRequestSerializerType apiRequestSerializerType;

/**
 *  同BaseAPI apiResponseSerializerType
 */
@property (nonatomic, assign) VPUPResponseSerializerType apiResponseSerializerType;

/**
 *  同BaseAPI apiRequestCachePolicy
 */
@property (nonatomic, assign) NSURLRequestCachePolicy apiRequestCachePolicy;

/**
 *  同BaseAPI apiRequestTimeoutInterval
 */
@property (nonatomic, assign) NSTimeInterval apiRequestTimeoutInterval;

/**
 *  DRDAPI Protocol中的 RequestParameters字段
 */
@property (nonatomic, strong, nullable) id requestParameters;

/**
 *  同BaseAPI apiRequestHTTPHeaderField
 */
@property (nonatomic, strong, nullable) NSDictionary *apiRequestHTTPHeaderField;

/**
 *  同BaseAPI apiResponseAcceptableContentTypes
 */
@property (nonatomic, strong, nullable) NSSet *apiResponseAcceptableContentTypes;

/**
 *  baseURL
 *  注意：如果API子类有设定baseURL, 则 Configuration 里的baseURL不起作用
 *  即： API里的baseURL 优先级更高
 */
@property (nonatomic, copy, nullable) NSString *baseUrl;

/**
 *  自定义的RequestUrl请求
 *  @descriptions:
 *     对于requestURL 处理为：
 *     当customeRequestUrl不为空时，将直接返回customRequestUrl作为请求数据
 *     而不去使用JSON-RPCProtocol 方式组装requestURL
 *
 *  @return url String
 */
@property (nonatomic, copy, nullable) NSString *customRequestUrl;

/**
 *  add a set method for call to define block
 */
- (void)setApiCompletionHandler:(nullable VPUPApiCompletionHandler)apiCompletionHandler;

/**
 *  一般用来进行JSON -> Model 数据的转换工作
 *   返回的id，如果没有error，则为转换成功后的Model数据；
 *    如果有error， 则直接返回传参中的responseObject
 *
 *  block param responseObject 请求的返回
 *  block param error          请求的错误
 *
 *  @return 整理过后的请求数据
 */
@property (nonatomic, copy, nullable) id _Nullable (^apiResponseObjReformerBlock)(id responseObject, NSError * _Nullable error);


- (instancetype)initWithRequestMethod:(NSString *)requestMethod;

@end
NS_ASSUME_NONNULL_END
