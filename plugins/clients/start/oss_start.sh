#!/bin/bash
# Copyright (c) 2012-2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINION=$1
. /etc/sysconfig/schoolserver
CLIENT=${MINION/.$SCHOOL_DOMAIN/}

#Set the license grains
IFS=$'\n'
for i in $( oss_api.sh GET softwares/devicesByName/${CLIENT}/licences )
do
	salt "$MINION" grains.set $i
done

#Apply high state
salt "$MINION" state.apply &> /dev/null

