#!/bin/bash
# Copyright (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu> Nürnberg, Germany.  All rights reserved.
# Copyright (c) 2012-2019 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINION=$1
. /etc/sysconfig/cranix
CLIENT=${MINION/.$CRANIX_DOMAIN/}

#Set the license grains
#IFS=$'\n'
LICENCES=$( crx_api_text.sh GET softwares/devicesByName/${CLIENT}/licences )
if [ "${LICENCES:0:7}" = '{"code"' ]; then
                exit
fi
if [ "${LICENCES}" ]; then
        salt "$MINION" grains.setvals ${LICENCES}
fi
#Sync modules
salt "$MINION" saltutil.sync_modules

#Disable windows update if CRANIX_ALLOW_WINDOWS_UPDATES is set
if [ "$CRANIX_ALLOW_WINDOWS_UPDATES" == "no" ]; then
	salt "$MINION" crx_client.disableUpdates
fi
#Apply high state
if [ "$CRANIX_DEBUG" == "yes" ]; then
	/usr/sbin/crx_apply_states.py "$MINION"
else
	/usr/sbin/crx_apply_states.py "$MINION" &> /dev/null
fi

#Now we can read the installed software on the minion
/usr/share/cranix/tools/read_installed_software.py $MINION

#Enable windows update if CRANIX_ALLOW_WINDOWS_UPDATES is set
if [ "$CRANIX_ALLOW_WINDOWS_UPDATES" == "yes" ]; then
	salt "$MINION" crx_client.enableUpdates
fi

