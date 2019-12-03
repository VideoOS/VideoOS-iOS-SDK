//
//  VPLuaRedirectAppletManager.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VPLuaRedirectAppletManager : NSObject

typedef NS_ENUM(NSUInteger, VPLuaRedirectOrientation) {
    VPLuaRedirectOrientationLandscape   = 1,
    VPLuaRedirectOrientationPortrait    = 2
};

typedef NS_ENUM(NSUInteger, VPLuaRedirectAppType) {
    VPLuaRedirectAppTypeAppLua  = 1,
    VPLuaRedirectAppTypeAppH5   = 2,
    VPLuaRedirectAppTypeTool    = 3
};

typedef void (^RedirectComplete)(BOOL success, NSError *error);

+ (void)redirectAppletWithDictionary:(NSDictionary *)appletDict
                  currentOrientation:(VPLuaRedirectOrientation)orientation
                       completeBlock:(RedirectComplete)completeBlock;

+ (void)redirectAppletWithAppletID:(NSString *)appletID
                           appType:(VPLuaRedirectAppType)appType
                           appData:(id)data
             needChangeOrientation:(VPLuaRedirectOrientation)changeOrientation
                currentOrientation:(VPLuaRedirectOrientation)currentOrientation
                     completeBlock:(RedirectComplete)completeBlock;


@end

