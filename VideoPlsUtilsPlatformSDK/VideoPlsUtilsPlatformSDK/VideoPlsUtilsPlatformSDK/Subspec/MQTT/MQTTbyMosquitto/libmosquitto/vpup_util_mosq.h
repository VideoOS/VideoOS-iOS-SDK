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
#ifndef vpup_util_mosq_h
#define vpup_util_mosq_h

#include <stdio.h>

#include "vpup_tls_mosq.h"
#include "vpup_mosquitto.h"

int _vpup_mosquitto_packet_alloc(struct _vpup_mosquitto_packet *packet);
void _vpup_mosquitto_check_keepalive(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_fix_sub_topic(char **subtopic);
uint16_t _vpup_mosquitto_mid_generate(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_topic_wildcard_len_check(const char *str);
FILE *_vpup_mosquitto_fopen(const char *path, const char *mode);

#ifdef REAL_WITH_TLS_PSK
int _vpup_mosquitto_hex2bin(const char *hex, unsigned char *bin, int bin_max_len);
#endif

#endif
