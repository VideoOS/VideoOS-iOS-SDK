//
//  VPUPReportEnum.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/10.
//  Copyright © 2017年 videopls. All rights reserved.
//

#ifndef VPUPReportEnum_h
#define VPUPReportEnum_h


#endif /* VPUPReportEnum_h */

typedef NS_ENUM(NSUInteger, VPUPReportLevel) {
    //普通信息打点,比如网络请求成功、按钮被点击等
    VPUPReportLevelInfo     = 0,
    //警告信息打点,比如网络请求出错、数据有错、逻辑有误等
    VPUPReportLevelWarning  = 1,
    //错误信息打点,应用crash,一般情况由平台来发送
    VPUPReportLevelError    = 2,
    //通过特定VPUPLog生成的report(无法通过addReport添加)
    VPUPReportLevelLog      = 3
};

typedef NS_OPTIONS(NSUInteger, VPUPReportEnable) {
    VPUPReportEnableInfo    = 1 << VPUPReportLevelInfo,             //1 << 0
    VPUPReportEnableWarning = 1 << VPUPReportLevelWarning,
    VPUPReportEnableError   = 1 << VPUPReportLevelError,
    VPUPReportEnableLog     = 1 << VPUPReportLevelLog
};
