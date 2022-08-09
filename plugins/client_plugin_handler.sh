#!/bin/bash
# Copyright (c) 2012-2022 Peter Varkoly <peter@varkoly.de> Nurember, Germany.  All rights reserved.

. /etc/sysconfig/cranix
what=$1
client=$2

if [ -d /usr/share/cranix/plugins/clients/$what ]
then
 cd /usr/share/cranix/plugins/clients/$what
 for i in `find -mindepth 1 -maxdepth 1 | sort`
 do
   /usr/share/cranix/plugins/clients/$what/$i $client
 done
fi

