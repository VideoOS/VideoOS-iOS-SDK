//
//  vpup_security_encode.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#ifndef vpup_security_encode_h
#define vpup_security_encode_h

#include <stdio.h>

#endif /* vpup_security_encode_h */

void vpup_token_encryption(char *cToken, const char *appKey, const char *json, const char *bundleID);

void vpup_mqtt_encryption(unsigned char* cMQTT, const char *key, const char *data);
