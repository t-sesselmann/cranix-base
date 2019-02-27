#!/bin/bash

U=$1

if [ -z "${U}" ]; then
	echo
	echo "Usage: /usr/share/oss/tools/clean_up_userWorkstations.sh <uid>"
	echo
	exit 1
fi
DN=$( /usr/sbin/oss_get_dn.sh ${U} )
if [ "${DN}" ]; then
        tmpldif=$( /usr/bin/mktemp /tmp/CleanUpWSXXXXXXXX )
        echo "${DN}" > ${tmpldif};
        echo "changetype: modify
delete: userWorkstations" >> ${tmpldif}
        /usr/bin/ldbmodify  -H /var/lib/samba/private/sam.ldb ${tmpldif}
	rm -f ${tmpldif}
fi
