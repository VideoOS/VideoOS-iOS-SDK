//
//  vpup_hash_encode.c
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#include "vpup_hash_encode.h"
#include <stdlib.h>
#include <string.h>
#include <CommonCrypto/CommonCrypto.h>

void vpup_trasform_hex_string(unsigned char *value, unsigned char *digest, int length) {
    for(int i = 0; i < length; i++)
    {
        sprintf((char *)&value[i * 2], "%02x",(unsigned int)digest[i]);
    }
}

void vpup_md5_encryption(char *str, unsigned char *cMD5) {
    if(((int)strlen(str)) == 1) {
        cMD5 = (unsigned char *)"";
        return;
    }
    
    char *encrypt = (char *)alloca((strlen(str) + 1) * sizeof(char));
    
    strcpy(encrypt, str);
    
    unsigned char *digest = (unsigned char *)alloca((CC_MD5_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_MD5_DIGEST_LENGTH + 1);
    
    CC_MD5(encrypt, (CC_LONG)strlen(encrypt), digest);
    
    vpup_trasform_hex_string(cMD5, digest, CC_MD5_DIGEST_LENGTH);
    
    return;
}

void vpup_md5_file_encryption(const void *data, long long size, unsigned char *cMD5) {
//    if(((int)sizeof(data)) == 1) {
//        cMD5 = (unsigned char *)"";
//        return;
//    }
//    
//    char *encrypt = (char *)alloca((strlen(str) + 1) * sizeof(char));
//    
//    strcpy(encrypt, str);
    
//    long length = sizeof(data) / sizeof(data[0]);
    
    unsigned char *digest = (unsigned char *)alloca((CC_MD5_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_MD5_DIGEST_LENGTH + 1);
    
    CC_MD5(data, (CC_LONG)size, digest);
    
    vpup_trasform_hex_string(cMD5, digest, CC_MD5_DIGEST_LENGTH);
    
    return;
}

void vpup_sha1_encryption(char *str, unsigned char *cSHA1) {
    if(((int)strlen(str)) == 1) {
        cSHA1 = (unsigned char *)"";
        return;
    }
    
    char *encrypt = (char *)alloca((strlen(str) + 1) * sizeof(char));
    
    strcpy(encrypt, str);
    
    unsigned char *digest = (unsigned char *)alloca((CC_SHA1_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_SHA1_DIGEST_LENGTH + 1);
    
    CC_SHA1(encrypt, (CC_LONG)strlen(encrypt), digest);
    
    vpup_trasform_hex_string(cSHA1, digest, CC_SHA1_DIGEST_LENGTH);
    return;
}

void vpup_sha256_encryption(char *str, unsigned char *cSHA256) {
    if(((int)strlen(str)) == 1) {
        cSHA256 = (unsigned char *)"";
        return;
    }
    
    char *encrypt = (char *)alloca((strlen(str) + 1) * sizeof(char));
    
    strcpy(encrypt, str);
    
    unsigned char *digest = (unsigned char *)alloca((CC_SHA256_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_SHA256_DIGEST_LENGTH + 1);
    
    CC_SHA256(encrypt, (CC_LONG)strlen(encrypt), digest);
    
    vpup_trasform_hex_string(cSHA256, digest, CC_SHA256_DIGEST_LENGTH);
    return;
}

void vpup_hmac_sha1_encryption(char *key, char *data, unsigned char *digest) {
    if(((int)strlen(key)) == 1 || ((int)strlen(data)) == 1) {
        return;
    }
    
    char *ckey = (char *)alloca((strlen(key)) * sizeof(char));
    strcpy(ckey, key);
    
    char *cdata = (char *)alloca((strlen(data)) * sizeof(char));
    strcpy(cdata, data);
    
    CCHmac(kCCHmacAlgSHA1, ckey, strlen(ckey), cdata, strlen(data), digest);
    return;
}

void vpup_hmac_sha1_bytes_encryption(char *key, char *data, unsigned char *cHMAC) {
    
    unsigned char *digest = (unsigned char *)alloca((CC_SHA1_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_SHA1_DIGEST_LENGTH + 1);
    vpup_hmac_sha1_encryption(key, data, digest);
    
    strcpy((char *)cHMAC, (char *)digest);
    return;
}

void vpup_hmac_sha1_hex_encryption(char *key, char *data, unsigned char *cHMAC) {

    unsigned char *digest = (unsigned char *)alloca((CC_SHA1_DIGEST_LENGTH + 1) * sizeof(unsigned char));
    memset(digest, '\0', CC_SHA1_DIGEST_LENGTH + 1);
    
    vpup_hmac_sha1_encryption(key, data, digest);
    
    vpup_trasform_hex_string(cHMAC, digest, CC_SHA1_DIGEST_LENGTH);
    return;
}

