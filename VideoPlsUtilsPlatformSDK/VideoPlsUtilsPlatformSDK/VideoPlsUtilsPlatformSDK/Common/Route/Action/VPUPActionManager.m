//
//  VPUPActionManager.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by 鄢江波 on 2017/8/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPUPActionManager.h"
#import "VPUPNotificationCenter.h"
#import "VPUPValidator.h"
#import "VPUPLogUtil.h"
#import "VPUPBase64Util.h"
#import "VPUPRoutes.h"

NSString *const VPUPLuaLoadErrorNotification = @"VPUPLuaLoadErrorNotification";
NSString *const VPUPLuaEndNotification = @"VPUPLuaEndNotification";

NSString *const VPUPActionTurnNotification = @"VPUPActionTurnNotification";
NSString *const VPUPActionTurnOffNotification = @"VPUPActionTurnOffNotification";

NSString *const VPUPGoodsListRequestNotification = @"VPUPGoodsListRequestNotification";
NSString *const VPUPGoodsListOpenPortraitWebViewNotification = @"VPUPGoodsListOpenPortraitWebViewNotification";
NSString *const VPUPGoodsListNativeEndNotification = @"VPUPGoodsListNativeEndNotification";

NSString *const VPUPDeviceNeedChangeToPortraitNotification = @"VPUPDeviceNeedChangeToPortraitNotification";


@implementation VPUPActionManager

+ (void)pushAction:(NSString *)action data:(id)data sender:(id)sender {
    
    if(action) {
        action = [VPUPBase64Util base64DecryptionString:action];
        NSURL *url = [NSURL URLWithString:action];
        if(!url) {
            VPUPLogW(@"native:%@", @"aciton is not url");
            return;
        }
        
        NSString *scheme = [url scheme];
        NSString *path = [NSString stringWithFormat:@"%@%@",[url host],[url path] ? [url path] : @""];
        
//        if ([scheme isEqualToString:@"turn"]) {
//            if(!VPUP_IsStringTrimExist(path)) {
//                VPUPLogW(@"native:%@", @"aciton's path is nil");
//                return;
//            }
//
//            NSMutableDictionary* info = [NSMutableDictionary dictionary];
//            [info setObject:path forKey:@"path"];
//            if(data) {
//                [info setObject:data forKey:@"data"];
//            }
//
//            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPActionTurnNotification object:sender userInfo:info];
//
//        }
//        else if ([scheme isEqualToString:@"turnOff"]) {
//            if(!VPUP_IsStringTrimExist(path)) {
//                VPUPLogW(@"native:%@", @"aciton's path is nil");
//                return;
//            }
//            
//            NSMutableDictionary* info = [NSMutableDictionary dictionary];
//            [info setObject:path forKey:@"path"];
//            if(data) {
//                [info setObject:data forKey:@"data"];
//            }
//            
//            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPActionTurnOffNotification object:sender userInfo:info];
//            
//        }
//        else
        if([scheme isEqualToString:@"webview"]) {
            //TODO: webview output
            
        }
        else if([scheme isEqualToString:@"GoodsList"]) {
            //TODO: new router
            //request
            if([path isEqualToString:@"request"]) {
                [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPGoodsListRequestNotification object:sender userInfo:nil];
            }
            //openWebView
            else if([path isEqualToString:@"openWebView"]) {
                NSDictionary *userInfo = nil;
                if(data) {
                    if([data isKindOfClass:[NSString class]]) {
                        userInfo = @{@"url":data};
                    }
                    else if([data isKindOfClass:[NSDictionary class]]) {
                        userInfo = data;
                    }
                }
                
                [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPGoodsListOpenPortraitWebViewNotification object:sender userInfo:userInfo];
            }
            // native end
            else if([path isEqualToString:@"nativeEnd"]) {
                [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPGoodsListNativeEndNotification object:sender userInfo:nil];
            }
        }
        else if([scheme isEqualToString:@"Lua"]) {
            NSDictionary *userInfo = nil;
            if(data) {
                if([data isKindOfClass:[NSString class]]) {
                    userInfo = @{@"name":data};
                }
                else if([data isKindOfClass:[NSDictionary class]]) {
                    userInfo = data;
                }
            }
            if([path isEqualToString:@"error"]) {
                [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPLuaLoadErrorNotification object:sender userInfo:userInfo];
            }
            else if([path isEqualToString:@"end"]) {
                //lua 关闭
                [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPLuaEndNotification object:sender userInfo:userInfo];
            }
        }
        else if ([scheme isEqualToString:@"device"]) {
            NSDictionary *userInfo = nil;
            if(data) {
                if([data isKindOfClass:[NSNumber class]]) {
                    userInfo = @{@"portrait":data};
                }
                else if([data isKindOfClass:[NSDictionary class]]) {
                    userInfo = data;
                }
            }
            [[VPUPNotificationCenter defaultCenter] postNotificationName:VPUPDeviceNeedChangeToPortraitNotification object:sender userInfo:userInfo];
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
            if (data) {
                [dict setObject:data forKey:@"ActionManagerData"];
            }
            if (sender) {
                [dict setObject:sender forKey:@"ActionManagerSender"];
            }
            [VPUPRoutes routeURL:url withParameters:dict];
        }
    }
    else {
        VPUPLogW(@"native:%@", @"aciton is nil");
    }
}

@end


NSString *VPUP_SchemeAddPath(NSString *actionPath, NSString *scheme) {
    if(VPUP_IsStringTrimExist(actionPath)) {
        if(VPUP_IsStringTrimExist(scheme)) {
            NSRange schemeRange = [scheme rangeOfString:@"://"];
            if(schemeRange.location != NSNotFound) {
                scheme = [scheme stringByReplacingCharactersInRange:schemeRange withString:@""];
            }
            if ([[actionPath substringToIndex:1] isEqualToString:@"/"]) {
                actionPath = [actionPath substringFromIndex:1];
            }
            return [VPUPBase64Util base64EncryptionString:[NSString stringWithFormat:@"%@://%@", scheme, actionPath]];
        }
    }
    return nil;
}

NSString *VPUP_TurnPath(NSString *actionPath) {
    return VPUP_SchemeAddPath(actionPath, @"turn");
}


