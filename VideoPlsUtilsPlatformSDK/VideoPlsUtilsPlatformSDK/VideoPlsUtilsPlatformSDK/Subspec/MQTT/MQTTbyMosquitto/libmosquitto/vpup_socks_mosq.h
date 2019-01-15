/*
Copyright (c) 2014 Roger Light <roger@atchoo.org>

All rights reserved. This program and the accompanying materials
are made available under the terms of the Eclipse Public License v1.0
and Eclipse Distribution License v1.0 which accompany this distribution.

The Eclipse Public License is available at
   http://www.eclipse.org/legal/epl-v10.html
and the Eclipse Distribution License is available at
  http://www.eclipse.org/org/documents/edl-v10.php.

Contributors:
   Roger Light - initial implementation and documentation.
*/

#ifndef vpup_socks_mosq_h
#define vpup_socks_mosq_h

int vpup_mosquitto__socks5_send(struct vpup_mosquitto *mosq);
int vpup_mosquitto__socks5_read(struct vpup_mosquitto *mosq);

#endif
