//
//  VPLuaAppletLandscapeContainer.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/30.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPLuaAppletObject.h"
#import "VPLuaNetworkManager.h"
#import "VPLuaVideoInfo.h"
#import "VPLuaAppletContainerDelegate.h"
#import "VPLuaAppletContainer.h"

@interface VPLuaAppletLandscapeContainer : UIView<VPLuaAppletContainer>



- (instancetype)initWithFrame:(CGRect)frame
                     appletID:(NSString *)appletID
               networkManager:(VPLuaNetworkManager *)networkManager
                    videoInfo:(VPLuaVideoInfo *)videoInfo
                      luaPath:(NSString *)luaPath
                         data:(id)data;


@end
