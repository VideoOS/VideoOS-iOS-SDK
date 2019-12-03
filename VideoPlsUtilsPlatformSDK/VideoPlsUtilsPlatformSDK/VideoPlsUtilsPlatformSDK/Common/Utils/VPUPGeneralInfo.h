//
//  VPUPGeneralInfo.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VPUPSDKInfo;

FOUNDATION_EXPORT NSString * const VideoPlsUtilsPlatformSDKVersion;

FOUNDATION_EXPORT NSString * const VPUPGeneralInfoSDKChangedNotification;

@interface VPUPGeneralInfo : NSObject


/**
 *  SDK相关信息需配置在SDKInfo中
 *  单独使用在初始化是配置一次即可
 *  融合包需要也持有一份,在视频开始时判断如果非自己的SDK配置需要重新设置一次SDKInfo
 *
 *  @param sdkInfo SDK配置相关内容
 */
+ (void)setSDKInfo:(VPUPSDKInfo *)sdkInfo;


/**
 *  获得当前SDKInfo
 *  @return SDKInfo
 */
+ (VPUPSDKInfo *)getCurrentSDKInfo;

/**
 *  是否是自身使用的SDKInfo(只是比指针,所以需要存储sdkInfo)
 *  @param sdkInfo 传入自己使用的sdkInfo
 *  @return 是否是自身的SDKInfo
 */
+ (BOOL)isEqualToSDKInfo:(VPUPSDKInfo *)sdkInfo;

/**
 *  bundle相关信息
 */
+ (NSString *)appName;
+ (NSString *)appBundleID;
+ (NSString *)appBundleName;
+ (NSString *)appBundleVersion;

/**
 *  设备相关信息
 */
+ (NSString *)appDeviceName;
+ (NSString *)appDeviceModel;
+ (NSString *)appDeviceSystemName;
+ (NSString *)appDeviceSystemVersion;
+ (NSString *)appDeviceLanguage;
+ (NSString *)iPhoneDeviceType;                         //手机机型


/**
 *  platformSDK版本
 */
+ (NSString *)platformSDKVersion;

/**
 *  VideoPlsSDK相关信息,需要先设置SDKInfo
 */
+ (NSString *)mainVPSDKName;
+ (NSString *)mainVPSDKVersion;
+ (NSString *)mainVPSDKServiceVersion;
+ (NSString *)mainVPSDKAppKey;
+ (NSString *)mainVPSDKAppSecret;
+ (NSString *)mainVPSDKPlatformID;                      //客户(例如:芒果,斗鱼)对应的ID,VideoOS使用ProjectID


/**
 *  设备IDFA,默认为空,需先设置
 */
+ (NSString *)IDFA;
+ (void)setIDFA:(NSString *)idfaString;



/**
 *  用户唯一标识(自己生成)
 */
+ (NSString *)userIdentity;
+ (void)setUserIdentity:(NSString *)identity;

@end
