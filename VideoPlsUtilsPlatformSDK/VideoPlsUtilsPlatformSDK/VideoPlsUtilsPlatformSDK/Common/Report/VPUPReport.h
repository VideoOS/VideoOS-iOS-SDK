//
//  VPUPReport.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/15.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPReportEnum.h"

@class VPUPHTTPBusinessAPI;

@interface VPUPReport : NSObject

/**
 *  在ApplicationdidFinishLaunch时需要生成
 */
+ (VPUPReport *)sharedReport;


//添加一条report
+ (void)addReportByLevel:(VPUPReportLevel)reportLevel
             reportClass:(Class)reportClass
                 message:(NSString *)message;

//添加一条图片请求错误report
+ (void)addImageWarningReportByReportClass:(Class)reportClass
                                     error:(NSError *)error
                                       url:(NSString *)url;

//添加一条HTTP请求返回结果有误
+ (void)addHTTPWarningReportByReportClass:(Class)reportClass
                                    error:(NSError *)error
                                      api:(VPUPHTTPBusinessAPI *)api;

//添加一条HTTP请求返回错误(如果是cancel则不发report)
+ (void)addHTTPErrorReportByReportClass:(Class)reportClass
                                  error:(NSError *)error
                                      api:(VPUPHTTPBusinessAPI *)api;

//添加一条下载请求错误report
+ (void)addDownloadWarningReportByReportClass:(Class)reportClass
                                        error:(NSError *)error
                                          url:(NSString *)url;

//添加一条下载成功但md5错误report
+ (void)addMD5WarningReportByReportClass:(Class)reportClass
                                   error:(NSError *)error
                                     url:(NSString *)url;

@end
