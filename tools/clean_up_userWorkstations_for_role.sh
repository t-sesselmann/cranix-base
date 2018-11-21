#!/bin/bash

ROLE=$1

if [ -z "$ROLE" ]; then
	echo
	echo "Usage: /usr/share/oss/tools/clean_up_userWorkstations.sh <role>"
	echo
	exit 1
fi
for U in $( /usr/sbin/oss_api.sh GET users/uidsByRole/${ROLE} )
do
        DN=$( oss_get_dn.sh ${U} )
        if [ "${DN}" ]; then
                tmpldif=$( mktemp /tmp/CleanUpWSXXXXXXXX )
                echo "${DN}" > ${tmpldif};
                echo "changetype: modify
delete: userWorkstations" >> ${tmpldif}
                /usr/bin/ldbmodify  -H /var/lib/samba/private/sam.ldb ${tmpldif}
		rm -f ${tmpldif}
        fi
done
