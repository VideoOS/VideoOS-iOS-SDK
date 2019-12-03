//
//  NSObject+VPLuaView.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by Zard1096-videojj on 2019/11/8.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VPLuaViewSDK/LVHeads.h>


@interface NSObject (NSObjectVPLuaView)<LVProtocal>

- (void)lv_buttonCallBack:(UIGestureRecognizer *)gesture;

@end

