//
//  VPUPDeviceUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 2018/4/24.
//  Copyright © 2018 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface VPUPDeviceUtil : NSObject

+ (BOOL)isIPhoneX;
+ (CGFloat)statusBarHeight;

+ (NSString *)phoneCarrier;

+ (int)phoneCarrierType;

@end
