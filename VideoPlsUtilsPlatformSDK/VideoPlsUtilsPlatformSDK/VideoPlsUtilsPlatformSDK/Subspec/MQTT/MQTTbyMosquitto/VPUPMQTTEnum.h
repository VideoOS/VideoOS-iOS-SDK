//
//  VPUPMQTTEnum.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 22/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#ifndef VPUPMQTTEnum_h
#define VPUPMQTTEnum_h

/**
 Enumeration of MQTT Quality of Service levels
 */
typedef NS_ENUM(UInt8, VPUPMQTTQoSLevel) {
    MQTTQoSLevelAtMostOnce  = 0,
    MQTTQoSLevelAtLeastOnce = 1,
    MQTTQoSLevelExactlyOnce = 2
};

#endif /* VPUPMQTTEnum_h */
