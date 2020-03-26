//
//  VPUPReportLogMessage.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/6/13.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPReportLogMessage.h"
#import "VPUPServerUTCDate.h"

@implementation VPUPReportLogMessage

- (NSString *)jsonValue {
    return [NSString stringWithFormat:@"%@%@\n", [VPUPServerUTCDate dateStringWithUnixTimeMillisecond:self.createTime], self.message];
}

@end
