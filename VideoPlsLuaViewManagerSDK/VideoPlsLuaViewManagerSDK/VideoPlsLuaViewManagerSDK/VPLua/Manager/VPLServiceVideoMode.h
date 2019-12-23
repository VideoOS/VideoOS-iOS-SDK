//
//  VPLServiceVideoMode.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 2019/7/29.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPLService.h"
#import "VPLOSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPLServiceVideoMode : VPLService

- (void)startServiceWithConfig:(VPLServiceConfig *)config complete:(VPLServiceCompletionBlock)complete;

@end

NS_ASSUME_NONNULL_END
