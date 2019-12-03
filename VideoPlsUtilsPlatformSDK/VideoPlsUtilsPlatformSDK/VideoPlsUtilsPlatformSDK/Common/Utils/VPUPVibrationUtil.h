//
//  VPUPVibrationUtil.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by zxh on 2019/11/12.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface VPUPVibrationUtil : NSObject

/// 开启震动
/// @param inCompletionBlock 震动完成的回调
+ (void)vibrateWithCompletion:(nullable void(^)(void))inCompletionBlock;

@end

NS_ASSUME_NONNULL_END
