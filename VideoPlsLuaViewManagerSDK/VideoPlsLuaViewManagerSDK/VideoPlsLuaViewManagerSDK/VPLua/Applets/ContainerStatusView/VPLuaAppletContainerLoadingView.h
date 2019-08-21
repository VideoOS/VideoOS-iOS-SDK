//
//  VPLuaAppletContainerLoadingView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/8/2.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaAppletContainerStatusView.h"

@interface VPLuaAppletContainerLoadingView : VPLuaAppletContainerStatusView

- (void)startLoading;
- (void)stopLoading;

@end

