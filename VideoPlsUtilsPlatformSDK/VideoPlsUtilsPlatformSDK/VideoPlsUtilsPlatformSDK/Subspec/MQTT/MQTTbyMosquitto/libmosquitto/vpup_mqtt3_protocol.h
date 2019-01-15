/*
Copyright (c) 2009-2013 Roger Light <roger@atchoo.org>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Neither the name of mosquitto nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef vpup_mqtt3_protocol_h
#define vpup_mqtt3_protocol_h

/* For version 3 of the MQTT protocol */

#define VP_MQTT_PROTOCOL_NAME_v31 "MQIsdp"
#define VP_MQTT_PROTOCOL_VERSION_v31 3

#define VP_MQTT_PROTOCOL_NAME_v311 "MQTT"
#define VP_MQTT_PROTOCOL_VERSION_v311 4

/* Message types */
#define VP_MQTT_CONNECT 0x10
#define VP_MQTT_CONNACK 0x20
#define VP_MQTT_PUBLISH 0x30
#define VP_MQTT_PUBACK 0x40
#define VP_MQTT_PUBREC 0x50
#define VP_MQTT_PUBREL 0x60
#define VP_MQTT_PUBCOMP 0x70
#define VP_MQTT_SUBSCRIBE 0x80
#define VP_MQTT_SUBACK 0x90
#define VP_MQTT_UNSUBSCRIBE 0xA0
#define VP_MQTT_UNSUBACK 0xB0
#define VP_MQTT_PINGREQ 0xC0
#define VP_MQTT_PINGRESP 0xD0
#define VP_MQTT_DISCONNECT 0xE0

#define VP_MQTT_CONNACK_ACCEPTED 0
#define VP_MQTT_CONNACK_REFUSED_PROTOCOL_VERSION 1
#define VP_MQTT_CONNACK_REFUSED_IDENTIFIER_REJECTED 2
#define VP_MQTT_CONNACK_REFUSED_SERVER_UNAVAILABLE 3
#define VP_MQTT_CONNACK_REFUSED_BAD_USERNAME_PASSWORD 4
#define VP_MQTT_CONNACK_REFUSED_NOT_AUTHORIZED 5

#define VP_MQTT_MAX_PAYLOAD 268435455

#endif
