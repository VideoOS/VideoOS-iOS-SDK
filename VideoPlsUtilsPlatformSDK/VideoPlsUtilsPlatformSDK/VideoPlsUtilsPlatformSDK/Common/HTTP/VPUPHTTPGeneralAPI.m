//
//  VPUPHTTPGeneralAPI.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPGeneralAPI.h"
#import "VPUPSecurityPolicy.h"
#import "VPUPHTTPHost.h"

@implementation VPUPHTTPGeneralAPI

#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        // 继承DRDBaseAPI 默认值
        self.apiRequestMethodType              = [super apiRequestMethodType];
//        self.apiPriority                       = [super apiPriority];
        self.apiRequestSerializerType          = [super apiRequestSerializerType];
        self.apiResponseSerializerType         = [super apiResponseSerializerType];
        self.apiRequestCachePolicy             = [super apiRequestCachePolicy];
        self.apiRequestTimeoutInterval         = [super apiRequestTimeoutInterval];
        self.apiRequestHTTPHeaderField         = [super apiRequestHTTPHeaderField];
        self.apiResponseAcceptableContentTypes = [super apiResponseAcceptableContentTypes];
        self.apiSecurityPolicy                 = [super apiSecurityPolicy];
//        self.apiAddtionalRPCParams             = [super apiAddtionalRPCParams];
//        self.apiAddtionalRequestFunction       = [super apiAddtionalRequestFunction];
//        self.customRequestUrl                  = [super customRequestUrl];
    }
    return self;
}

- (instancetype)initWithRequestMethod:(NSString *)requestMethod {
    self = [self init];
    if(self) {
        self.requestMethod = requestMethod;
    }
    return self;
}

- (NSURL *)requestURL {
    NSURL *url = nil;
    if ([self customRequestUrl]) {
        if([[self customRequestUrl] isKindOfClass:[NSURL class]]) {
            url = (NSURL *)[self customRequestUrl];
        } else {
            url = [NSURL URLWithString:[self customRequestUrl]];
        }
    }
    else if (self.baseUrl) {
        url = [NSURL URLWithString:[self requestMethod] ? : @""
                     relativeToURL:[NSURL URLWithString:[self baseUrl]]];
    }
    //VPUPLog(@"url = %@, baseUrl = %@, host = %@",url.absoluteString,url.baseURL.absoluteString,url.host);
    return [VPUPHTTPHost urlForCurrentEnvironment:url];
}

- (nullable id)apiResponseObjReformer:(id)responseObject andError:(NSError * _Nullable)error {
    
    if (self.apiResponseObjReformerBlock) {
        return self.apiResponseObjReformerBlock(responseObject, error);
    }
    
    return responseObject;
}

- (VPUPHTTPAPIPriority)apiPriority {
    return VPUPHTTPAPIPriorityHigh;
}

- (nonnull VPUPSecurityPolicy *)apiSecurityPolicy {
    VPUPSecurityPolicy *securityPolicy;
    securityPolicy = [VPUPSecurityPolicy policyWithPinningMode:VPUPSSLPinningModeNone];
    return securityPolicy;
}

- (void)setApiCompletionHandler:(VPUPApiCompletionHandler)apiCompletionHandler {
    [super setApiCompletionHandler:apiCompletionHandler];
}

@end
