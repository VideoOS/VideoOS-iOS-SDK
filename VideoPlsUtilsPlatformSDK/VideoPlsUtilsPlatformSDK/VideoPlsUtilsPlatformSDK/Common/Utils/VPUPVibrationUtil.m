//
//  VPUPVibrationUtil.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by zxh on 2019/11/12.
//  Copyright © 2019 videopls. All rights reserved.
//

#import "VPUPVibrationUtil.h"

@implementation VPUPVibrationUtil

+ (void)vibrateWithCompletion:(nullable void (^)(void))inCompletionBlock{
    
    if (@available(iOS 9.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
            if (inCompletionBlock) {
                inCompletionBlock();
            }
        });
    } else {
        // Fallback on earlier versions
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        if (inCompletionBlock) {
            inCompletionBlock();
        }
    }
    
}
@end
