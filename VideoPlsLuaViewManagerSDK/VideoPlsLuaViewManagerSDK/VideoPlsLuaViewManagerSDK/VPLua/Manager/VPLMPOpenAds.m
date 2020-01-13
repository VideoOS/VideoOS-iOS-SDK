//
//  VPLMPOpenAds.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/12/25.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPLMPOpenAds.h"
#import <UIKit/UIKit.h>
#import "VPUPValidator.h"
#import "VPUPEncryption.h"
#import "VPLNativeBridge.h"

@implementation VPLMPOpenAds

+ (void)openAdsWithParams:(NSDictionary *)params {
    
    if (!params) {
        return;
    }
    
    if (![params objectForKey:@"targetType"]) {
        return;
    }
    
    NSInteger targetType = [[params objectForKey:@"targetType"] integerValue];
    if (targetType < 1 || targetType > 3) {
        return;
    }
    
    if (targetType != 3) {
        //open url
        [self openUrlWithParams:params];
    } else {
        //打开app store
        if (![params objectForKey:@"linkData"] || ![[params objectForKey:@"linkData"] objectForKey:@"linkUrl"]) {
            return;
        }
        
        NSString *resUrl = [[params objectForKey:@"linkData"] objectForKey:@"linkUrl"];
        NSURL *deepUrl = [NSURL URLWithString:resUrl];
        if (!deepUrl) {
            return;
        }
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:deepUrl];
        if (canOpen) {
            [[UIApplication sharedApplication] openURL:deepUrl options:nil completionHandler:^(BOOL success) {
                
            }];
        }
    }
}

+ (NSInteger)openUrlWithParams:(NSDictionary *)params {
    
    NSInteger returnValue = 0;
    if (![params objectForKey:@"linkData"]) {
        return returnValue;
    }
    
    NSDictionary *dict = [params objectForKey:@"linkData"];
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionary];
    
    NSString *actionString = nil;
    NSString *linkUrl = nil;
    NSString *deepLink = nil;
    NSString *selfLink = nil;
    if (VPUP_IsStrictExist([dict objectForKey:@"linkUrl"]) && [[dict objectForKey:@"linkUrl"] isKindOfClass:[NSString class]]) {
        linkUrl = [dict objectForKey:@"linkUrl"];
        [sendParams setObject:linkUrl forKey:@"linkUrl"];
    }
    if (VPUP_IsStrictExist([dict objectForKey:@"deepLink"]) && [[dict objectForKey:@"deepLink"] isKindOfClass:[NSString class]]) {
        deepLink = [dict objectForKey:@"deepLink"];
        [sendParams setObject:deepLink forKey:@"deepLink"];
    }
    if (VPUP_IsStrictExist([dict objectForKey:@"selfLink"]) && [[dict objectForKey:@"selfLink"] isKindOfClass:[NSString class]]) {
        selfLink = [dict objectForKey:@"selfLink"];
        [sendParams setObject:selfLink forKey:@"selfLink"];
    }
    
    if (linkUrl != nil) {
        actionString = linkUrl;
    } else if (deepLink != nil) {
        actionString = deepLink;
    } else if (selfLink != nil) {
        actionString = selfLink;
    }
    
    if (!actionString) {
        return returnValue;
    }
    
    [sendParams setObject:actionString forKey:@"actionString"];
    [sendParams setObject:@(3) forKey:@"eventType"];    //eventTypeClick
    [sendParams setObject:@(1) forKey:@"actionType"];   //actionTypeOpenUrl
    
    NSString *adID = [VPUPMD5Util md5HashString:actionString];
    if ([params objectForKey:@"adsId"]) {
        adID = [params objectForKey:@"adsId"];
    }
    [sendParams setObject:adID forKey:@"adID"];
    
    NSString *adName = @"";
    if ([params objectForKey:@"slogan"]) {
        adName = [params objectForKey:@"slogan"];
    }
    [sendParams setObject:adName forKey:@"adName"];
    
    if (deepLink) {
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:deepLink]];
        if (canOpen) {
            returnValue = 1;
        } else {
            returnValue = 2;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VPLActionNotification object:nil userInfo:sendParams];
    
    return returnValue;
}


@end
