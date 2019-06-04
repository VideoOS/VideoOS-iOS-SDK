//
//  VPUPHTTPBaseAPI.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPBaseAPI.h"
#import "VPUPSecurityPolicy.h"
#import "VPUPMD5Util.h"
#import "VPUPRPCProtocol.h"
#import "VPUPAutoNumberIDUtil.h"

@interface VPUPHTTPBaseAPI()

@property (nonatomic, assign) NSUInteger apiId;
@property (nonatomic, assign) NSUInteger retryCount;

@end

@implementation VPUPHTTPBaseAPI

- (instancetype)init {
    self = [super init];
    if (self) {
        _apiId = [VPUPAutoNumberIDUtil getUniqueID];
        _retryCount = 0;
    }
    return self;
}

- (void)setRetryCount:(NSUInteger)retryCount {
    _retryCount = retryCount;
}

- (nullable NSURL *)requestURL {
    return nil;
}

- (nullable NSString *)requestMethod {
    return nil;
}

- (nullable id)requestParameters {
    return nil;
}

- (VPUPRequestMethodType)apiRequestMethodType {
    return VPUPRequestMethodTypeGET;
}

- (VPUPHTTPAPIPriority)apiPriority {
    return VPUPHTTPAPIPriorityDefault;
}

- (VPUPRequestSerializerType)apiRequestSerializerType {
    return VPUPRequestSerializerTypeJSON;
}

- (VPUPResponseSerializerType)apiResponseSerializerType {
    return VPUPResponseSerializerTypeJSON;
}

- (NSURLRequestCachePolicy)apiRequestCachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSTimeInterval)apiRequestTimeoutInterval {
    return VPUP_API_REQUEST_TIME_OUT;
}

- (nullable NSDictionary *)apiRequestHTTPHeaderField {
    return @{
             @"Content-Type" : @"application/json; charset=utf-8",
             };
}

- (nullable NSSet *)apiResponseAcceptableContentTypes {
    return [NSSet setWithObjects:
            @"text/json",
            @"text/plain",
            @"application/json",
//            @"image/gif",
            @"text/javascript", nil];
}

/**
 *  为了方便，在Debug模式下使用None来保证用Charles之类可以抓到HTTPS报文
 *  Production下，则用Pinning Certification PublicKey 来防止中间人攻击
 *  
 *  暂不防止中间人攻击
 */
- (nonnull VPUPSecurityPolicy *)apiSecurityPolicy {
    VPUPSecurityPolicy *securityPolicy;
#ifdef DEBUG
    securityPolicy = [VPUPSecurityPolicy policyWithPinningMode:VPUPSSLPinningModeNone];
#else
    securityPolicy = [VPUPSecurityPolicy policyWithPinningMode:VPUPSSLPinningModePublicKey];
#endif
    return securityPolicy;
}

- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error {
    return responseObject;
}

- (NSUInteger)hash {
    NSMutableString *hashStr = [NSMutableString stringWithFormat:@"%@ %@", [self requestParameters], self.requestURL.absoluteString];
    return [[VPUPMD5Util md5HashString:hashStr] hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, requestURL: %@>", NSStringFromClass([self class]), self, self.requestURL.absoluteString];
}

@end
