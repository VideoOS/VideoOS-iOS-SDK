//
//  vpup_aes.c
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#include "vpup_aes.h"
#include "string.h"
#include "vpup_security_string.h"

#define VPUP_AES_XOR_KEY 0xAF

void vpup_aesInitVector(unsigned char *cIV) {
    unsigned char iv[] = {
        (VPUP_AES_XOR_KEY ^ 'l'),
        (VPUP_AES_XOR_KEY ^ 'x'),
        (VPUP_AES_XOR_KEY ^ '7'),
        (VPUP_AES_XOR_KEY ^ 'e'),
        (VPUP_AES_XOR_KEY ^ 'Z'),
        (VPUP_AES_XOR_KEY ^ 'h'),
        (VPUP_AES_XOR_KEY ^ 'V'),
        (VPUP_AES_XOR_KEY ^ 'o'),
        (VPUP_AES_XOR_KEY ^ 'B'),
        (VPUP_AES_XOR_KEY ^ 'E'),
        (VPUP_AES_XOR_KEY ^ 'n'),
        (VPUP_AES_XOR_KEY ^ 'K'),
        (VPUP_AES_XOR_KEY ^ 'X'),
        (VPUP_AES_XOR_KEY ^ 'E'),
        (VPUP_AES_XOR_KEY ^ 'L'),
        (VPUP_AES_XOR_KEY ^ 'F'),
        (VPUP_AES_XOR_KEY ^ '\0')
    };
    
    vpup_get_safe_string(iv, VPUP_AES_XOR_KEY);
    
//    memcpy(*cIV, iv, sizeof(iv));
    strcpy((char *)cIV, (char *)iv);
}

void vpup_aesDefaultKey(unsigned char *cKey) {
    unsigned char key[] = {
        (VPUP_AES_XOR_KEY ^ '8'),
        (VPUP_AES_XOR_KEY ^ 'l'),
        (VPUP_AES_XOR_KEY ^ 'g'),
        (VPUP_AES_XOR_KEY ^ 'K'),
        (VPUP_AES_XOR_KEY ^ '5'),
        (VPUP_AES_XOR_KEY ^ 'f'),
        (VPUP_AES_XOR_KEY ^ 'r'),
        (VPUP_AES_XOR_KEY ^ '5'),
        (VPUP_AES_XOR_KEY ^ 'y'),
        (VPUP_AES_XOR_KEY ^ 'a'),
        (VPUP_AES_XOR_KEY ^ 't'),
        (VPUP_AES_XOR_KEY ^ 'O'),
        (VPUP_AES_XOR_KEY ^ 'f'),
        (VPUP_AES_XOR_KEY ^ 'H'),
        (VPUP_AES_XOR_KEY ^ 'i'),
        (VPUP_AES_XOR_KEY ^ 'o'),
        (VPUP_AES_XOR_KEY ^ '\0')
    };
    
    vpup_get_safe_string(key, VPUP_AES_XOR_KEY);
    
//    memcpy(*cKey, key, sizeof(key));
    strcpy((char *)cKey, (char *)key);
}
