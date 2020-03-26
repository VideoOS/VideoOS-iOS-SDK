//
//  VPUPReportMessage.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/16.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPUPReportMessage.h"
#import "VPUPJsonUtil.h"
#import "VPUPServerUTCDate.h"
#import "VPUPAutoNumberIDUtil.h"

@implementation VPUPReportMessage

+ (VPUPReportMessage *)reportMessageWith:(VPUPReportLevel)level
                             reportClass:(NSString *)reportClassString
                                 message:(NSString *)message {
    VPUPReportMessage *reportMessage = [[self alloc] init];
    [reportMessage setLevel:level];
    [reportMessage setReportClass:reportClassString];
    [reportMessage setMessage:message];
    [reportMessage setCreateTime:[VPUPServerUTCDate currentUnixTimeMillisecond]];
    return reportMessage;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _reportID = [NSString stringWithFormat:@"%lu", (unsigned long)[VPUPAutoNumberIDUtil getReportID]];
        _level = 0;
    }
    return self;
}

- (NSString *)uniqueReportID {
    return [NSString stringWithFormat:@"%0.0lf|%@",_createTime, _reportID];
}

- (NSString *)levelString {
    NSString *levelString = @"";
    switch (_level) {
        case VPUPReportLevelInfo:
            levelString = @"info";
            break;
        case VPUPReportLevelWarning:
            levelString = @"warning";
            break;
        case VPUPReportLevelError:
            levelString = @"error";
            break;
        case VPUPReportLevelLog:
            levelString = @"u";
            break;
        default:
            break;
    }
    return levelString;
}

- (NSString *)jsonValue {
    NSString *levelString = [self levelString];
    NSDictionary *jsonDict = @{@"level"         : levelString,
                               @"tag"           : _reportClass ?: @"",
                               @"message"       : _message ?: @"",
                               @"create_time"   : [NSString stringWithFormat:@"%0.0lf",_createTime]};
    
    NSString *json = VPUP_DictionaryToJson(jsonDict);
    return json;
}


@end
