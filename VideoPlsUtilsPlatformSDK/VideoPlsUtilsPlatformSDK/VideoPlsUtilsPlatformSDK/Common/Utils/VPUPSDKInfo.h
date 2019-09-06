//
//  VPUPSDKInfo.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/11.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VPUPMainSDKType) {
    VPUPMainSDKTypeVideoOS          = 0,
    VPUPMainSDKTypeLiveOS           = 1,
    VPUPMainSDKTypeVideojj          = 2
};

@interface VPUPSDKInfo : NSObject

@property (nonatomic, copy, readonly) NSString *mainVPSDKName;
@property (nonatomic, assign, readonly) VPUPMainSDKType mainVPSDKType;
@property (nonatomic, copy, readonly) NSString *mainVPSDKVersion;
@property (nonatomic, copy, readonly) NSString *mainVPSDKServiceVersion;
@property (nonatomic, copy, readonly) NSString *mainVPSDKAppKey;                    //独立项目appKey
@property (nonatomic, copy, readonly) NSString *mainVPSDKAppSecret;
@property (nonatomic, copy, readonly) NSString *mainVPSDKPlatformID;                //平台ID(例如:芒果、新蓝等平台方面的唯一标示,可能需要从后台获取)
@property (nonatomic, assign, readonly, getter=enableWebP) BOOL webP;


- (VPUPSDKInfo *)initSDKInfoWithSDKType:(VPUPMainSDKType)sdkType
                             SDKVersion:(NSString *)sdkVersion
                                 appKey:(NSString *)appKey;

- (VPUPSDKInfo *)initSDKInfoWithSDKType:(VPUPMainSDKType)sdkType
                             SDKVersion:(NSString *)sdkVersion
                                 appKey:(NSString *)appKey
                             enableWebP:(BOOL)webP;


- (void)setMainSDKNameByType:(VPUPMainSDKType)sdkType;
- (void)setMainVPSDKVersion:(NSString *)sdkVersion;
- (void)setMainVPSDKAppKey:(NSString *)appKey;
- (void)setMainVPSDKAppSecret:(NSString *)appSecret;
- (void)setEnableWebP:(BOOL)webP;

//需后台拿到数据后才能添加,其他通过初始化生成
- (void)setMainVPSDKPlatformID:(NSString *)platformID;
- (void)setMainVPSDKServiceVersion:(NSString *)serviceVersion;

@end
