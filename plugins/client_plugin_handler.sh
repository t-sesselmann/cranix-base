#!/bin/bash
# Copyright (c) 2012-2018 Peter Varkoly <peter@varkoly.de> Nurember, Germany.  All rights reserved.

. /etc/sysconfig/schoolserver
what=$1
client=$2

if [ -d /usr/share/oss/plugins/clients/$what ]
then
 cd /usr/share/oss/plugins/clients/$what
 for i in `find -mindepth 1 -maxdepth 1`
 do
   /usr/share/oss/plugins/clients/$what/$i $client &
 done
fi

