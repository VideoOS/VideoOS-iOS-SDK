//
//  VPLuaTrackApi.h
//  VideoPlsLuaViewSDK
//
//  Created by peter on 17/11/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import <VideoPlsUtilsPlatformSDK/VideoPlsUtilsPlatformSDK.h>

@interface VPLuaTrackApi : VPUPHTTPBusinessAPI

-(instancetype)initWithTrackEventCat:(NSUInteger)cat
                              params:(NSMutableDictionary *)params;

@end
