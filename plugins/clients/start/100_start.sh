#!/bin/bash
# Copyright (c) 2012-2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINION=$1
. /etc/sysconfig/schoolserver
CLIENT=${MINION/.$SCHOOL_DOMAIN/}

#Set the license grains
#IFS=$'\n'
LICENCES=$( oss_api_text.sh GET softwares/devicesByName/${CLIENT}/licences )
if [ "${LICENCES:0:7}" = '{"code"' ]; then
                exit
fi
if [ "${LICENCES}" ]; then
        salt "$MINION" grains.setvals ${LICENCES}
fi

#Apply high state
salt "$MINION" state.apply &> /dev/null

#Now we can read the installed software on the minion
/usr/share/oss/tools/read_installed_software.pl $MINION

