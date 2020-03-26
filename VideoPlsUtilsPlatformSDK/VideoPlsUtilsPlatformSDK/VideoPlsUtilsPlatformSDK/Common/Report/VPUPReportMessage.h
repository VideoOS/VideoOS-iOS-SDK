//
//  VPUPReportMessage.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPReport.h"

@interface VPUPReportMessage : NSObject

/**
 *  通知ID
 */
@property (nonatomic, copy, readonly) NSString *reportID;

/**
 *  通知信息等级
 */
@property (nonatomic, assign) VPUPReportLevel level;


/**
 *  打点的类名
 */
@property (nonatomic, copy) NSString *reportClass;


/**
 *  打点的信息
 *  如网络请求则在message中传api即可
 */
@property (nonatomic, copy) NSString *message;


/**
 *  创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

+ (VPUPReportMessage *)reportMessageWith:(VPUPReportLevel)level
                             reportClass:(NSString *)reportClassString
                                 message:(NSString *)message;

- (NSString *)uniqueReportID;

- (NSString *)jsonValue;

@end
