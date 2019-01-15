/*
Copyright (c) 2010-2013 Roger Light <roger@atchoo.org>
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
#ifndef vpup_send_mosq_h
#define vpup_send_mosq_h

#include "vpup_mosquitto.h"

int _vpup_mosquitto_send_simple_command(struct vpup_mosquitto *mosq, uint8_t command);
int _vpup_mosquitto_send_command_with_mid(struct vpup_mosquitto *mosq, uint8_t command, uint16_t mid, bool dup);
int _vpup_mosquitto_send_real_publish(struct vpup_mosquitto *mosq, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup);

int _vpup_mosquitto_send_connect(struct vpup_mosquitto *mosq, uint16_t keepalive, bool clean_session);
int _vpup_mosquitto_send_disconnect(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_send_pingreq(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_send_pingresp(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_send_puback(struct vpup_mosquitto *mosq, uint16_t mid);
int _vpup_mosquitto_send_pubcomp(struct vpup_mosquitto *mosq, uint16_t mid);
int _vpup_mosquitto_send_publish(struct vpup_mosquitto *mosq, uint16_t mid, const char *topic, uint32_t payloadlen, const void *payload, int qos, bool retain, bool dup);
int _vpup_mosquitto_send_pubrec(struct vpup_mosquitto *mosq, uint16_t mid);
int _vpup_mosquitto_send_pubrel(struct vpup_mosquitto *mosq, uint16_t mid, bool dup);
int _vpup_mosquitto_send_subscribe(struct vpup_mosquitto *mosq, int *mid, bool dup, const char *topic, uint8_t topic_qos);
int _vpup_mosquitto_send_unsubscribe(struct vpup_mosquitto *mosq, int *mid, bool dup, const char *topic);

#endif
