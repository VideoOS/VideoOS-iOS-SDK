//
//  VPLuaServiceAd.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/26.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaService.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLuaServiceAd : VPLuaService

- (void)startServiceWithConfig:(VPLuaServiceConfig *)config complete:(VPLuaServiceCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
