//
//  VPIServiceConfig.h
//  VideoPlsInterfaceControllerSDK
//
//  Created by peter on 2019/7/28.
//  Copyright © 2019 videopls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPIServiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface VPIServiceConfig : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) VPIServiceType type;
@property (nonatomic, assign) VPIVideoAdTimeType duration;

@property (nonatomic, assign) VPIVideoModeType videoModeType;
@property (nonatomic, assign) CGPoint eyeOriginPoint;

@end

NS_ASSUME_NONNULL_END
