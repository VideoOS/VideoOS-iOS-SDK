//
//  VPUPVideo.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/11/21.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPUPVideo : NSObject

@property (nonatomic, strong) NSURL *url;
/// 视频播放时长，默认为视频原始时长
@property (nonatomic, assign) NSInteger ex;

@end
