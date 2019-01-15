//
//  VPUPSecurityPolicy.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPHTTPAPIEnum.h"

@interface VPUPSecurityPolicy : NSObject

/**
 *  SSL Pinning证书的校验模式
 *  默认为 VPUPSSLPinningModeNone
 */
@property (readonly, nonatomic, assign) VPUPSSLPinningMode SSLPinningMode;

/**
 *  是否允许使用Invalid 证书
 *  默认为 NO
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 *  是否校验在证书 CN 字段中的 domain name
 *  默认为 YES
 */
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 *  创建新的SecurityPolicy
 *
 *  @param pinningMode 证书校验模式
 *
 *  @return 新的SecurityPolicy
 */
+ (instancetype)policyWithPinningMode:(VPUPSSLPinningMode)pinningMode;

@end
