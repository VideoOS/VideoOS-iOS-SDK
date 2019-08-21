//
//  VPLuaAppletContainerDelegate.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/7/31.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol VPLuaAppletContainerDelegate <NSObject>

- (void)deleteContainerWithAppletID:(NSString *)appletID;

- (void)closeAllContainers;

@end

