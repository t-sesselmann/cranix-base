#!/bin/bash
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
# Copyright (c) 2009 Peter Varkoly Fuerth, Germany.  All rights reserved.
#
# syntax: /usr/sbin/oss_get_access_status room
#
. /etc/sysconfig/schoolserver

STATUS=$( /usr/bin/firewall-cmd --info-zone=$1 )
DIRECT=$( echo "$STATUS" | grep masquerade: | sed 's/.*masquerade: //' )
LOGIN=$(  echo "$STATUS" | grep address=\"$SCHOOL_SERVER\" )
PORTAL=$( echo "$STATUS" | grep address=\"$SCHOOL_MAILSERVER\")
PROXY=$(  echo "$STATUS" | grep address=\"$SCHOOL_PROXY\"  )
PRINT=$(  echo "$STATUS" | grep address=\"$SCHOOL_PRINTSERVER\" )

if [ "$DIRECT" = "yes" ]; then
	echo -n '{"direct":true,'
else
	echo -n '{"direct":false,'
fi
if [ "$PROXY" ]; then
	echo -n '"proxy":false,'
else
	echo -n '"proxy":true,'
fi
if [ "$LOGIN" ]; then
	echo -n '"login":false,'
else
	echo -n '"login":true,'
fi
if [ "$PORTAL" ]; then
	echo -n '"portal":false,'
else
	echo -n '"portal":true,'
fi
if [ "$PRINT" ]; then
	echo -n '"print":false}'
else
	echo -n '"print":true}'
fi
