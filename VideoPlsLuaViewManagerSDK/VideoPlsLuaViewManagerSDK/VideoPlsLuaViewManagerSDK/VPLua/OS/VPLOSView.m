//
//  VPLOSView.m
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 05/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPLOSView.h"
#import "VideoPlsUtilsPlatformSDK.h"

@implementation VPLOSView

- (void)startLoading {
    [super startLoading];
    [self openMainPage];
}

- (void)stop {
    [super stop];
    [self deregisterLuaActionNotification];
}

- (void)initLuaView {
    [super initLuaView];
    [self registerLuaActionNotification];
}

- (void)openMainPage {
    [self loadLFile:@"main.lua" data:nil];
}

- (void)registerLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] addObserver:self selector:@selector(luaEnd:) name:VPUPLEndNotification object:self.nodeController];
}

- (void)deregisterLuaActionNotification {
    [[VPUPNotificationCenter defaultCenter] removeObserver:self name:VPUPLEndNotification object:self.nodeController];
}

- (void)luaEnd:(NSNotification *)notification {
    NSString *name = [notification.userInfo objectForKey:@"name"];
    if ([name isEqualToString:@"main.lua"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VPOSLuaEndNotification object:nil];
    }
}

@end
