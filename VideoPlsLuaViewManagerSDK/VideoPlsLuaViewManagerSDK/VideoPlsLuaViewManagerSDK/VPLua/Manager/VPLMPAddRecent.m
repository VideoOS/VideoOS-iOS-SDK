//
//  VPLMPAddRecent.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/12/24.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPAddRecent.h"
#import "VPUPLocalStorage.h"
#import "VPUPGeneralInfo.h"
#import "VPUPJsonUtil.h"

@implementation VPLMPAddRecent

+ (void)addRecentWithMPID:(NSString *)mpID {
    
    NSString *recentString = [VPUPLocalStorage getStorageDataWithFile:[VPUPGeneralInfo userIdentity] key:@"recentMiniAppId"];
    
    NSMutableArray *mpArray = [NSMutableArray array];
    
    if (recentString) {
        NSArray *dataArray = VPUP_JsonToDictionary(recentString);
        if (dataArray && [dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            [mpArray addObjectsFromArray:dataArray];
        }
    }
    
    if ([mpArray containsObject:mpID]) {
        [mpArray removeObject:mpID];
    }
    
    [mpArray insertObject:mpID atIndex:0];
    
    if ([mpArray count] > 21) {
        [mpArray removeObjectsInRange:NSMakeRange(21, [mpArray count] - 21)];
    }
    
    NSString *savedString = VPUP_DictionaryToJson(mpArray);
    
    [VPUPLocalStorage setStorageDataWithFile:[VPUPGeneralInfo userIdentity] key:@"recentMiniAppId" value:savedString];
    
}

@end
