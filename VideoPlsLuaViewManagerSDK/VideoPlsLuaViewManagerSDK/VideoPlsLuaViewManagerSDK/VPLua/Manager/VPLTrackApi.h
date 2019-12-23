//
//  VPLTrackApi.h
//  VideoPlsLuaViewSDK
//
//  Created by peter on 17/11/2017.
//  Copyright © 2017 videopls. All rights reserved.
//

#import "VideoPlsUtilsPlatformSDK.h"

@interface VPLTrackApi : VPUPHTTPBusinessAPI

-(instancetype)initWithTrackEventCat:(NSUInteger)cat
                              params:(NSMutableDictionary *)params;

@end
