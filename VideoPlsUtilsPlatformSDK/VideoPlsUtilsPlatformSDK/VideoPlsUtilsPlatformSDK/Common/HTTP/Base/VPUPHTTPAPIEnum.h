//
//  VPUPHTTPAPIEnum.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#ifndef VPUPHTTPAPIEnum_h
#define VPUPHTTPAPIEnum_h

// 网络请求类型
typedef NS_ENUM(NSUInteger, VPUPRequestMethodType) {
    VPUPRequestMethodTypeGET        = 0,
    VPUPRequestMethodTypePOST       = 1,
    VPUPRequestMethodTypeHEAD       = 2,
    VPUPRequestMethodTypePUT        = 3,
    VPUPRequestMethodTypePATCH      = 4,
    VPUPRequestMethodTypeDELETE     = 5,
    VPUPRequestMethodTypeDOWNLOAD   = 6,
    VPUPRequestMethodTypeUPLOAD     = 7
};

// 请求的序列化格式
typedef NS_ENUM(NSUInteger, VPUPRequestSerializerType) {
    VPUPRequestSerializerTypeHTTP    = 0,
    VPUPRequestSerializerTypeJSON    = 1
};

// 请求返回的序列化格式
typedef NS_ENUM(NSUInteger, VPUPResponseSerializerType) {
    VPUPResponseSerializerTypeHTTP    = 0,
    VPUPResponseSerializerTypeJSON    = 1
};

/**
 *  SSL Pinning
 */
typedef NS_ENUM(NSUInteger, VPUPSSLPinningMode) {
    /**
     *  不校验Pinning证书
     */
    VPUPSSLPinningModeNone,
    /**
     *  校验Pinning证书中的PublicKey.
     *  知识点可以参考
     *  https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
     */
    VPUPSSLPinningModePublicKey,
    /**
     *  校验整个Pinning证书
     */
    VPUPSSLPinningModeCertificate,
};

/**
 *  网络请求优先级(参照dispatch的priority)
 */
typedef NS_ENUM(NSInteger, VPUPHTTPAPIPriority) {
    VPUPHTTPAPIPriorityLow          = -2,
    VPUPHTTPAPIPriorityDefault      =  0,
    VPUPHTTPAPIPriorityHigh         =  2
};

// VPUP 默认的请求超时时间
#define VPUP_API_REQUEST_TIME_OUT     15
#define VPUP_MAX_HTTP_CONNECTION_PER_HOST 5

#endif /* VPUPHTTPAPIEnum_h */
