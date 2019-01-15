//
//  VPUPIPAddressUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/8/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPIPAddressUtil : NSObject

+ (NSString *)currentIpAddress;
+ (NSDictionary *)getIPAddresses;

@end
