//
//  VPUPNetworkErrorObserverProtocol.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/9.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VPUPNetworkErrorObserverProtocol <NSObject>

/**
 *  发生HTTP层网络错误时，通过该函数进行监控回调
 *
 *  @param error 网络错误的Error
 */
- (void)networkErrorWithErrorInfo:(nonnull NSError *)error;

@end
