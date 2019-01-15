//
//  VPUPHTTPBusinessAPI.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPHTTPGeneralAPI.h"

/**
 *  详细参数配置见HTTPGeneralAPI,BusinessAPI添加了业务需要使用的常规Header参数
 *  如业务需要新增Header则继承此类,重写 apiRequestHTTPHeaderField 方法
 *  调用[super apiRequestHTTPHeaderField]能获得之前的Header,businessAPI中返回的参数为NSMutableDictionary,可直接添加
 */
@interface VPUPHTTPBusinessAPI : VPUPHTTPGeneralAPI

@property (nonatomic, assign, getter=needEncrypted) BOOL encrypted;

- (void)encryptedParameters;

@end
