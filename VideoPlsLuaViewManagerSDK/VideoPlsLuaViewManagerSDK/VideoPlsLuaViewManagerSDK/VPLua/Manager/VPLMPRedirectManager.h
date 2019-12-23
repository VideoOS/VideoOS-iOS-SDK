//
//  VPLMPRedirectManager.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/20.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VPLMPRedirectManager : NSObject

typedef NS_ENUM(NSUInteger, VPLMPRedirectOrientation) {
    VPLMPRedirectOrientationLandscape   = 1,
    VPLMPRedirectOrientationPortrait    = 2
};

typedef NS_ENUM(NSUInteger, VPLRedirectAppType) {
    VPLRedirectAppTypeAppLua        = 1,
    VPLRedirectAppTypeAppHybird     = 2,
    VPLRedirectAppTypeTool          = 3
};

typedef void (^RedirectComplete)(BOOL success, NSError *error);

+ (void)redirectMPWithDictionary:(NSDictionary *)mpDict
              currentOrientation:(VPLMPRedirectOrientation)orientation
                   completeBlock:(RedirectComplete)completeBlock;

+ (void)redirectMPWithMPID:(NSString *)mpID
                   appType:(VPLRedirectAppType)appType
                   appData:(id)data
     needChangeOrientation:(VPLMPRedirectOrientation)changeOrientation
        currentOrientation:(VPLMPRedirectOrientation)currentOrientation
             completeBlock:(RedirectComplete)completeBlock;


@end

