//
//  VPUPHTTPBaseAPI.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIEnum.h"
@class VPUPSecurityPolicy;
@protocol VPUPRPCProtocol;

NS_ASSUME_NONNULL_BEGIN

//completehandle. if call a duplicate api will return already send api's task and get error message for cancel
typedef void (^VPUPApiCompletionHandler)(_Nonnull id responseObject, NSError * _Nullable error, NSURLResponse * _Nullable response);

//For download type use, to set download file final destination
typedef NSURL* _Nonnull (^VPUPApiDownloadDestination)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response);


#pragma mark -
@protocol VPUPMultipartFormData <NSObject>
    
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                        error:(NSError * __nullable __autoreleasing *)error;
    
- (BOOL)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                        error:(NSError * __nullable __autoreleasing *)error;
- (void)appendPartWithInputStream:(nullable NSInputStream *)inputStream
                             name:(NSString *)name
                         fileName:(NSString *)fileName
                           length:(int64_t)length
                         mimeType:(NSString *)mimeType;
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;
    
- (void)appendPartWithFormData:(NSData *)data
                          name:(NSString *)name;
- (void)appendPartWithHeaders:(nullable NSDictionary *)headers
                         body:(NSData *)body;
- (void)throttleBandwidthWithPacketSize:(NSUInteger)numberOfBytes
                                  delay:(NSTimeInterval)delay;
    
@end

#pragma mark -
//TODO 未使用后面删除该protocol，及上层的使用
@protocol VPUPHttpHeaderDelegate <NSObject>
    
- (nullable NSDictionary *)apiRequestHTTPHeaderField;
    
@end

@interface VPUPHTTPBaseAPI : NSObject


/**
 *  发送completeBlock使用的线程
 *  可手动配置,如果为空则默认为main_queue
 */
@property (nullable, nonatomic, weak) dispatch_queue_t callbackQueue;

/**
 *  用户api请求的URL
 */
@property (nullable, nonatomic, readonly) NSURL *requestURL;

/**
 *  用户api请求的唯一标识
 */
@property (nonatomic, assign, readonly) NSUInteger apiId;

/**
 *  用户api请求失败后重试的次数
 */
@property (nonatomic, assign, readonly) NSUInteger retryCount;

- (void)setRetryCount:(NSUInteger)retryCount;

/**
 *  用户api请求中的参数列表
 *   如果JSON-RPC协议，则Parameters 放入JSON-RPC协议中
 *   如果非JSON-RPC协议，则requestParameters 会作为url的一部分发送给服务器
 *
 *  @return 一般来说是NSDictionary
 */
- (nullable id)requestParameters;

/**
 *  请求的类型:GET, POST
 *  @default
 *   VPUPRequestMethodTypeGet
 *
 *  @return VPUPRequestMethodType
 */
- (VPUPRequestMethodType)apiRequestMethodType;

/**
 *  Request 序列化类型：JSON, HTTP, 见VPUPRequestSerializerType
 *  @default
 *   VPUPResponseSerializerTypeJSON
 *
 *  @return VPUPRequestSerializerTYPE
 */
- (VPUPRequestSerializerType)apiRequestSerializerType;

/**
 *  Response 序列化类型： JSON, HTTP
 *
 *  @return VPUPResponseSerializerType
 */
- (VPUPResponseSerializerType)apiResponseSerializerType;

/**
 *  HTTP 请求的Cache策略
 *  @default
 *   NSURLRequestUseProtocolCachePolicy
 *
 *  @return NSURLRequestCachePolicy
 */
- (NSURLRequestCachePolicy)apiRequestCachePolicy;

/**
 *  HTTP 请求超时的时间
 *  @default
 *    API_REQUEST_TIME_OUT
 *
 *  @return 超时时间
 */
- (NSTimeInterval)apiRequestTimeoutInterval;

/**
 *  HTTP 请求的头部区域自定义
 *  @default
 *   默认为：@{
 *               @"Content-Type" : @"application/json; charset=utf-8"
 *           }
 *
 *  @return NSDictionary
 */
- (nullable NSDictionary *)apiRequestHTTPHeaderField;

/**
 *  HTTP 请求的返回可接受的内容类型
 *  @default
 *   默认为：[NSSet setWithObjects:
 *            @"text/json",
 *            @"text/html",
 *            @"application/json",
 *            @"text/javascript", nil];
 *
 *  @return NSSet
 */
- (nullable NSSet *)apiResponseAcceptableContentTypes;

/**
 *  HTTPS 请求的Security策略
 *
 *  @return HTTPS证书验证策略
 */
- (nonnull VPUPSecurityPolicy *)apiSecurityPolicy;

/**
 *  一般用来进行JSON -> Model 数据的转换工作
 *   返回的id，如果没有error，则为转换成功后的Model数据；
 *    如果有error， 则直接返回传参中的responseObject
 *
 *  @param responseObject 请求的返回
 *  @param error          请求的错误
 *
 *  @return 默认直接返回responseObject
 */
- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error;

/**
 *  api完成后的执行体
 *  responseObject: api 返回的数据结构(download type中返回的是fileUrl)
 *  error:  api 返回的错误信息
 */
@property (nonatomic, copy, nullable) VPUPApiCompletionHandler apiCompletionHandler;

/**
 *  用于组织POST体的block
 */
@property (nonatomic, copy, nullable) void (^apiRequestConstructingBodyBlock)(id<VPUPMultipartFormData> _Nonnull formData);

@end


NS_ASSUME_NONNULL_END
