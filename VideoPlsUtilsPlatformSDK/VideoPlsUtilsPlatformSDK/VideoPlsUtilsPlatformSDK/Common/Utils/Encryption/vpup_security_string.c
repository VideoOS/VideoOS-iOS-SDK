//
//  vpup_security_string.c
//  VideoPlsUtilsPlatformSDK
//
//  Created by Zard1096 on 2017/5/14.
//  Copyright © 2017年 videopls. All rights reserved.
//

#include "vpup_security_string.h"

void vpup_get_safe_string(unsigned char *str, unsigned char key) {
    unsigned char *p = str;
    while( ((*p) ^=  key) != '\0')  p++;
}
