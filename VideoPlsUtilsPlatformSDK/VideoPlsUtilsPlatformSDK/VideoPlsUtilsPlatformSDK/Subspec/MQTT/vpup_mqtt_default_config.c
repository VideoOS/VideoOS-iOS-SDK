//
//  vpup_mqtt_default_config.c
//  VideoPlsUtilsPlatformSDK
//
//  Created by 李少帅 on 2017/5/24.
//  Copyright © 2017年 videopls. All rights reserved.
//

#include "vpup_mqtt_default_config.h"
#include "string.h"
#include "vpup_security_string.h"

#define VPUP_MQTT_XOR_KEY 0xBD

void vpup_mqtt_default_user_name(unsigned char *c_name) {
    unsigned char name[] = {
        (VPUP_MQTT_XOR_KEY ^ 'C'),
        (VPUP_MQTT_XOR_KEY ^ 'S'),
        (VPUP_MQTT_XOR_KEY ^ 'w'),
        (VPUP_MQTT_XOR_KEY ^ 't'),
        (VPUP_MQTT_XOR_KEY ^ 'M'),
        (VPUP_MQTT_XOR_KEY ^ 's'),
        (VPUP_MQTT_XOR_KEY ^ 'B'),
        (VPUP_MQTT_XOR_KEY ^ 'f'),
        (VPUP_MQTT_XOR_KEY ^ '6'),
        (VPUP_MQTT_XOR_KEY ^ 'O'),
        (VPUP_MQTT_XOR_KEY ^ 'X'),
        (VPUP_MQTT_XOR_KEY ^ 'p'),
        (VPUP_MQTT_XOR_KEY ^ 'r'),
        (VPUP_MQTT_XOR_KEY ^ 'z'),
        (VPUP_MQTT_XOR_KEY ^ 'j'),
        (VPUP_MQTT_XOR_KEY ^ 'S'),
        (VPUP_MQTT_XOR_KEY ^ '\0')
    };
    
    vpup_get_safe_string(name, VPUP_MQTT_XOR_KEY);
    memcpy(c_name, name, 17);
//    strcpy((char *)c_name, (char *)name);
}

void vpup_mqtt_default_key(unsigned char *c_key) {
    
    unsigned char key[] = {
        (VPUP_MQTT_XOR_KEY ^ 'P'),
        (VPUP_MQTT_XOR_KEY ^ 'H'),
        (VPUP_MQTT_XOR_KEY ^ 'V'),
        (VPUP_MQTT_XOR_KEY ^ 'G'),
        (VPUP_MQTT_XOR_KEY ^ 'C'),
        (VPUP_MQTT_XOR_KEY ^ '1'),
        (VPUP_MQTT_XOR_KEY ^ 'G'),
        (VPUP_MQTT_XOR_KEY ^ 'I'),
        (VPUP_MQTT_XOR_KEY ^ 'Q'),
        (VPUP_MQTT_XOR_KEY ^ 'p'),
        (VPUP_MQTT_XOR_KEY ^ 'w'),
        (VPUP_MQTT_XOR_KEY ^ 'D'),
        (VPUP_MQTT_XOR_KEY ^ 'Q'),
        (VPUP_MQTT_XOR_KEY ^ 'n'),
        (VPUP_MQTT_XOR_KEY ^ 'x'),
        (VPUP_MQTT_XOR_KEY ^ 'E'),
        (VPUP_MQTT_XOR_KEY ^ 'b'),
        (VPUP_MQTT_XOR_KEY ^ 'v'),
        (VPUP_MQTT_XOR_KEY ^ 'G'),
        (VPUP_MQTT_XOR_KEY ^ 'e'),
        (VPUP_MQTT_XOR_KEY ^ 'B'),
        (VPUP_MQTT_XOR_KEY ^ 'b'),
        (VPUP_MQTT_XOR_KEY ^ 'G'),
        (VPUP_MQTT_XOR_KEY ^ '2'),
        (VPUP_MQTT_XOR_KEY ^ '7'),
        (VPUP_MQTT_XOR_KEY ^ 's'),
        (VPUP_MQTT_XOR_KEY ^ 'e'),
        (VPUP_MQTT_XOR_KEY ^ 'J'),
        (VPUP_MQTT_XOR_KEY ^ 'l'),
        (VPUP_MQTT_XOR_KEY ^ 'w'),
        (VPUP_MQTT_XOR_KEY ^ '\0')
    };
    
    vpup_get_safe_string(key, VPUP_MQTT_XOR_KEY);
    memcpy(c_key, key, 31);
//    strcpy((char *)c_key, (char *)key);
    
}

void vpup_mqtt_default_customer_id(unsigned char *c_id) {
    
    unsigned char id[] = {
        (VPUP_MQTT_XOR_KEY ^ 'C'),
        (VPUP_MQTT_XOR_KEY ^ 'I'),
        (VPUP_MQTT_XOR_KEY ^ 'D'),
        (VPUP_MQTT_XOR_KEY ^ '_'),
        (VPUP_MQTT_XOR_KEY ^ 's'),
        (VPUP_MQTT_XOR_KEY ^ 'u'),
        (VPUP_MQTT_XOR_KEY ^ 'b'),
        (VPUP_MQTT_XOR_KEY ^ '_'),
        (VPUP_MQTT_XOR_KEY ^ 'I'),
        (VPUP_MQTT_XOR_KEY ^ 'O'),
        (VPUP_MQTT_XOR_KEY ^ 'S'),
        (VPUP_MQTT_XOR_KEY ^ '\0')
    };
    
    vpup_get_safe_string(id, VPUP_MQTT_XOR_KEY);
    memcpy(c_id, id, 12);
//    strcpy((char *)c_id, (char *)id);
    
}
