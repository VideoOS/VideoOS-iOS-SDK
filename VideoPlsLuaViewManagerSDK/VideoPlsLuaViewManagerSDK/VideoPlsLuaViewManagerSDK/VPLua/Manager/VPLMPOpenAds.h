//
//  VPLMPOpenAds.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/12/25.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPLMPOpenAds : NSObject

/// 打开广告
/// @param params ads参数,详见http://wiki.videojj.com/pages/viewpage.action?pageId=3250376
/// @return 能否打开deepLink
+ (void)openAdsWithParams:(NSDictionary *)params;

/// 打开外链(linkUrl, deepLink)
/// @param params ads参数,详见http://wiki.videojj.com/pages/viewpage.action?pageId=3250376
/// @return 0非deepLink,1能打开deepLink,2不能打开deepLink
+ (NSInteger)openUrlWithParams:(NSDictionary *)params;

@end

