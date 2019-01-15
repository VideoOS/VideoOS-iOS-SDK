//
//  vpup_security_encode.c
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#include "vpup_security_encode.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpup_hash_encode.h"

void vpup_token_encryption(char *cToken, const char *appKey, const char *json, const char *bundleID) {
    char *allStr = (char *)alloca((strlen(json)+strlen(appKey)+strlen(bundleID) + 1) * sizeof(char));
    memset(allStr, '\0', strlen(json)+strlen(appKey)+strlen(bundleID) + 1);
    strcpy(allStr, json);
    strcat(allStr, appKey);
    strcat(allStr, bundleID);
    
    //    char *finalEncryption = (char *)malloc(100 * sizeof(char));
//    strcpy(cToken, vpup_md5_encryption(vpup_sha256_encryption(vpup_sha256_encryption(vpup_md5_encryption(allStr)))));
    
    vpup_md5_encryption(allStr, (unsigned char *)cToken);
    vpup_sha256_encryption(cToken, (unsigned char *)cToken);
    vpup_sha256_encryption(cToken, (unsigned char *)cToken);
    vpup_md5_encryption(cToken, (unsigned char *)cToken);
    
    return;
}

void vpup_mqtt_encryption(unsigned char* cMQTT, const char *key, const char *data) {
    char *ckey = (char *)alloca((strlen(key) + 1) * sizeof(char));
    char *cdata = (char *)alloca((strlen(data) + 1) * sizeof(char));
    memset(ckey, '\0', strlen(key) + 1);
    memset(cdata, '\0', strlen(data) + 1);
    
    strcpy(ckey, key);
    strcpy(cdata, data);
    
    vpup_hmac_sha1_bytes_encryption(ckey, cdata, cMQTT);
}
