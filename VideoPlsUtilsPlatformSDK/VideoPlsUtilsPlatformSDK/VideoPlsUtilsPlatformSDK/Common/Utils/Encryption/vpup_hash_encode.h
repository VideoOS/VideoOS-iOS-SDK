//
//  vpup_hash_encode.h
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/12.
//  Copyright © 2017年 videopls. All rights reserved.
//

#ifndef vpup_hash_encode_h
#define vpup_hash_encode_h

#include <stdio.h>

#endif /* vpup_hash_encode_h */

void vpup_md5_encryption(char *str, unsigned char *cMD5);
void vpup_md5_file_encryption(const void *data, long long size, unsigned char *cMD5);

void vpup_sha1_encryption(char *str, unsigned char *cSHA1);
void vpup_sha256_encryption(char *str, unsigned char *cSHA256);

//void vpup_hmac_sha1_encrption(const *key, char *data, unsigned char *digest);
void vpup_hmac_sha1_bytes_encryption(char *key, char *data, unsigned char *cHMAC);
void vpup_hmac_sha1_hex_encryption(char *key, char *data, unsigned char *cHMAC);
