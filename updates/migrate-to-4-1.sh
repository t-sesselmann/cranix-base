#!/bin/bash
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#
# Check if the script should be executed.
if [ -e /etc/firewalld/zones/ANON_DHCP.xml ];
then
	echo "This server was already migrated to OSS-4.1 or is a new installed OSS-4.1"
	exit 
fi
# Since 4.1 we have OUs
# We have to create it and move the users into the corresponding OU

for ROLE in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/primary )
do
	samba-tool ou create OU=${ROLE}
	for U in $( /usr/sbin/oss_api.sh GET users/uidsByRole/${ROLE} )
	do
		samba-tool user move ${U} OU=${ROLE}
	done
done

# Now we have to create firewalld Zones for the rooms
/usr/share/oss/updates/migrate-to-4-1.py

