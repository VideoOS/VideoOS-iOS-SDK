//
//  VPUPLocalStorage.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096-videojj on 2019/12/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPLocalStorage.h"
#import "VPUPPathUtil.h"
#import "VPUPJsonUtil.h"

@implementation VPUPLocalStorage

//fileName 只用传developerUserId或对应id，不用带plist
+ (void)setStorageDataWithFile:(NSString *)fileName
                           key:(NSString *)key
                         value:(NSString *)value {
    
    NSString *filePath = [VPUPPathUtil localStoragePath];
    NSString *fileNamePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, @".plist"]];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileNamePath];
    if (!dataDict) {
        dataDict = [NSMutableDictionary dictionary];
    }
    
    if (value != nil) {
        [dataDict setValue:value forKey:key];
    } else {
        //value == nil, remove key
        if ([dataDict objectForKey:key]) {
            [dataDict removeObjectForKey:key];
        }
    }
    
    [dataDict writeToFile:fileNamePath atomically:YES];
}

+ (NSString *)getStorageDataWithFile:(NSString *)fileName
                                 key:(NSString *)key {
    
    NSString *filePath = [VPUPPathUtil localStoragePath];
    NSString *fileNamePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, @".plist"]];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithContentsOfFile:fileNamePath];
    
    if (!dataDict) {
        return nil;
    }
    
    NSString *sendParamString = nil;
    
    if (key == nil) {
        sendParamString = VPUP_DictionaryToJson(dataDict);
    } else {
        if ([dataDict objectForKey:key]) {
            sendParamString = [dataDict objectForKey:key];
        }
    }
    
    return sendParamString;
}


@end
