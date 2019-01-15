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
#ifndef vpup_messages_mosq_h
#define vpup_messages_mosq_h

#include "vpup_mosquitto_internal.h"
#include "vpup_mosquitto.h"

void _vpup_mosquitto_message_cleanup_all(struct vpup_mosquitto *mosq);
void _vpup_mosquitto_message_cleanup(struct vpup_mosquitto_message_all **message);
int _vpup_mosquitto_message_delete(struct vpup_mosquitto *mosq, uint16_t mid, enum vpup_mosquitto_msg_direction dir);
void _vpup_mosquitto_message_queue(struct vpup_mosquitto *mosq, struct vpup_mosquitto_message_all *message, bool doinc);
void _vpup_mosquitto_messages_reconnect_reset(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_message_remove(struct vpup_mosquitto *mosq, uint16_t mid, enum vpup_mosquitto_msg_direction dir, struct vpup_mosquitto_message_all **message);
void _vpup_mosquitto_message_retry_check(struct vpup_mosquitto *mosq);
int _vpup_mosquitto_message_update(struct vpup_mosquitto *mosq, uint16_t mid, enum vpup_mosquitto_msg_direction dir, enum vpup_mosquitto_msg_state state);

#endif
