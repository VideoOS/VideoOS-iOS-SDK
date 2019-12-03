//
//  VPLuaRedirectAppletManager.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLuaRedirectAppletManager.h"
#import "VPUPActionManager.h"
#import "VPLuaAppletRequest.h"
#import "VPLuaLoader.h"
#import "VPUPTrafficStatistics.h"
#import "VPUPPathUtil.h"
#import "VPUPValidator.h"
#import "VPUPRandomUtil.h"
#import "VPLuaNativeBridge.h"

@implementation VPLuaRedirectAppletManager


+ (void)redirectAppletWithDictionary:(NSDictionary *)appletDict
                  currentOrientation:(VPLuaRedirectOrientation)currentOrientation
                       completeBlock:(RedirectComplete)completeBlock {
    if (!VPUP_IsStrictExist([appletDict objectForKey:@"appletId"]) || ![[appletDict objectForKey:@"appletId"] isKindOfClass:[NSString class]]) {
        return;
    }
    if (![appletDict objectForKey:@"screenType"]) {
        return;
    }
    if (![appletDict objectForKey:@"appType"]) {
        return;
    }
    
    __block NSString *appletId = [appletDict objectForKey:@"appletId"];
    __block NSInteger screenType = [[appletDict objectForKey:@"screenType"] integerValue];
    if (screenType < 1 || screenType > 2) {
        screenType = 1;
    }
    NSInteger appType = [[appletDict objectForKey:@"appType"] integerValue];
    if (appType < 1 || appType > 3) {
        appType = 1;
    }
    
    __block id data = [appletDict objectForKey:@"data"];
    
    [self redirectAppletWithAppletID:appletId
                             appType:appType
                             appData:data
               needChangeOrientation:screenType
                  currentOrientation:currentOrientation
                       completeBlock:completeBlock];
    
}

+ (void)redirectAppletWithAppletID:(NSString *)appletID
                           appType:(VPLuaRedirectAppType)appType
                           appData:(id)data
             needChangeOrientation:(VPLuaRedirectOrientation)changeOrientation
                currentOrientation:(VPLuaRedirectOrientation)currentOrientation
                     completeBlock:(RedirectComplete)completeBlock {
    
    if (appType != VPLuaRedirectAppTypeTool) {
        //B类小程序内部跳转
        NSString *schemePath = [NSString stringWithFormat:@"applets?appletId=%@&type=%d&appType=%d", appletID, changeOrientation, appType];
        
        [VPUPActionManager pushAction:VPUP_SchemeAddPath(schemePath, @"LuaView") data:data sender:self];
    } else {
        //需打开A类小工具
        __weak typeof(self) weakSelf = self;
        [[VPLuaAppletRequest request] requestToolWithID:appletID apiManager:nil complete:^(VPMiniAppInfo *appInfo, NSError *error) {
            
             if (error) {
                //错误提示？？
                return;
            }
            
            __block typeof(appInfo) blockAppInfo = appInfo;
            
           [[VPLuaLoader sharedLoader] checkAndDownloadFilesListWithAppInfo:blockAppInfo complete:^(NSError * _Nonnull error, VPUPTrafficStatisticsList *trafficList) {
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
                
                NSString *schemePath = [NSString stringWithFormat:@"defaultLuaView?template=%@&id=%@%@", blockAppInfo.templateLua, blockAppInfo.appletID, [VPUPRandomUtil randomStringByLength:3]];
                
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
                if (changeOrientation == VPLuaRedirectOrientationLandscape) {
                    [dict setObject:@(2) forKey:@"orientation"];
                } else {
                    [dict setObject:@(1) forKey:@"orientation"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:VPLuaScreenChangeNotification object:nil userInfo:dict];
            }];
        }];
    }
    
}

@end
