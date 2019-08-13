//
//  VPLuaServiceVideoMode.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLuaService.h"
#import "VPLuaOSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLuaServiceVideoMode : VPLuaService

- (void)startServiceWithConfig:(VPLuaServiceConfig *)config complete:(VPLuaServiceCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
