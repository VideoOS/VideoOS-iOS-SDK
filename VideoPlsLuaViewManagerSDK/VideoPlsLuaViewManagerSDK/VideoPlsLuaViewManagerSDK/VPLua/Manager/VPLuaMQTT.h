//
//  VPLuaMQTT.h
//  VideoPlsLuaViewManagerSDK
//
//  Created by peter on 08/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LVHeads.h"
#import "LVNativeObjBox.h"
#import "NSObject+LuaView.h"

@interface VPLuaMQTT : LVNativeObjBox

- (id)init:(lua_State*) l;

+ (int)lvClassDefine:(lua_State *)L globalName:(NSString*) globalName;

@end
