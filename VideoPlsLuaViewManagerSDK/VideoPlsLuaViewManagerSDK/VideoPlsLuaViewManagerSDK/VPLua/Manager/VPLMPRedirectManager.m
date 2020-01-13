//
//  VPLMPRedirectManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPRedirectManager.h"
#import "VPUPActionManager.h"
#import "VPLMPRequest.h"
#import "VPLDownloader.h"
#import "VPUPTrafficStatistics.h"
#import "VPUPPathUtil.h"
#import "VPUPValidator.h"
#import "VPUPRandomUtil.h"
#import "VPLNativeBridge.h"

@implementation VPLMPRedirectManager


+ (void)redirectMPWithDictionary:(NSDictionary *)mpDict
                  currentOrientation:(VPLMPRedirectOrientation)currentOrientation
                       completeBlock:(RedirectComplete)completeBlock {
    if (!VPUP_IsStrictExist([mpDict objectForKey:@"appletId"]) || ![[mpDict objectForKey:@"appletId"] isKindOfClass:[NSString class]]) {
        return;
    }
    if (![mpDict objectForKey:@"screenType"]) {
        return;
    }
    if (![mpDict objectForKey:@"appType"]) {
        return;
    }
    
    __block NSString *mpID = [mpDict objectForKey:@"appletId"];
    __block NSInteger screenType = [[mpDict objectForKey:@"screenType"] integerValue];
    if (screenType < 1 || screenType > 2) {
        screenType = 1;
    }
    NSInteger appType = [[mpDict objectForKey:@"appType"] integerValue];
    if (appType < 1 || appType > 3) {
        appType = 1;
    }
    
    __block id data = [mpDict objectForKey:@"data"];
    
    NSInteger level = -1;
    if ([mpDict objectForKey:@"level"] && [[mpDict objectForKey:@"level"] integerValue]) {
        level = [[mpDict objectForKey:@"level"] integerValue];
    }
    
    [self redirectMPWithMPID:mpID
                         appType:appType
                         appData:data
           needChangeOrientation:screenType
              currentOrientation:currentOrientation
                       level:level
                   completeBlock:completeBlock];
    
}

+ (void)redirectMPWithMPID:(NSString *)mpID
                           appType:(VPLRedirectAppType)appType
                           appData:(id)data
             needChangeOrientation:(VPLMPRedirectOrientation)changeOrientation
                currentOrientation:(VPLMPRedirectOrientation)currentOrientation
                                level:(NSInteger)level
                     completeBlock:(RedirectComplete)completeBlock {
    
    if (appType != VPLRedirectAppTypeTool) {
        //B类小程序内部跳转
        NSString *schemePath = [NSString stringWithFormat:@"applets?appletId=%@&type=%d&appType=%d", mpID, changeOrientation, appType];
        
        [VPUPActionManager pushAction:VPUP_SchemeAddPath(schemePath, @"LuaView") data:data sender:self];
    } else {
        //需打开A类小工具
        __weak typeof(self) weakSelf = self;
        [[VPLMPRequest request] requestToolWithID:mpID apiManager:nil complete:^(VPMiniAppInfo *appInfo, NSError *error) {
            
             if (error) {
                //错误提示？？
                return;
            }
            
            __block typeof(appInfo) blockAppInfo = appInfo;
            
           [[VPLDownloader sharedDownloader] checkAndDownloadFilesListWithAppInfo:blockAppInfo complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
                //已回到主线程
                if (trafficList) {
                    [VPUPTrafficStatistics sendTrafficeStatistics:trafficList type:VPUPTrafficTypeRealTime];
                }
                
                if (error) {
                    //错误提示？？
                    return;
                }
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:data forKey:@"data"];
                [params setObject:[blockAppInfo dictionaryValue] forKey:@"miniAppInfo"];
                
                NSString *schemePath = [NSString stringWithFormat:@"defaultLuaView?template=%@&id=%@%@", blockAppInfo.template, blockAppInfo.mpID, [VPUPRandomUtil randomStringByLength:3]];
               
               if (level >= 5) {
                   schemePath = [schemePath stringByReplacingOccurrencesOfString:@"defaultLuaView" withString:@"topLuaView" options:0 range:NSMakeRange(0, 15)];
               }
                
                [VPUPActionManager pushAction:VPUP_SchemeAddPath(schemePath, @"LuaView") data:params sender:weakSelf];
                
                if (completeBlock) {
                    completeBlock(YES, nil);
                }
                
                if (currentOrientation == changeOrientation) {
                    return;
                }
                
                //通知改横屏
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
                //1是横屏切竖屏,2是竖屏切横屏
                if (changeOrientation == VPLMPRedirectOrientationLandscape) {
                    [dict setObject:@(2) forKey:@"orientation"];
                } else {
                    [dict setObject:@(1) forKey:@"orientation"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VPLScreenChangeNotification object:nil userInfo:dict];
            }];
        }];
    }
    
}

@end
