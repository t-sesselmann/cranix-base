#!/bin/bash

U=$1
I=$2
a=$3
m=$4
R=$5


crx_api.sh PUT devices/loggedInUsers/$I/$U

. /etc/sysconfig/cranix
role=$( crx_api_text.sh GET users/byUid/$U/role )

case "${role}" in
	workstations)
	;;
	students)
		if [ "${CRANIX_ALLOW_STUDENTS_MULTIPLE_LOGIN}" = "no" ]; then
			DN=$( crx_get_dn.sh ${U} )
		fi
	;;
	*)
		if [ "${CRANIX_ALLOW_MULTIPLE_LOGIN}" = "no" ]; then
			DN=$( crx_get_dn.sh ${U} )
		fi 
esac

if [ "${DN}" ]; then
	tmpldif=$( mktemp /tmp/XXXXXXXX )
	echo "${DN}" > ${tmpldif};
	echo "changetype: modify
add: userWorkstations
userWorkstations: ${m}" >> ${tmpldif}
        ldbmodify  -H /var/lib/samba/private/sam.ldb ${tmpldif}
        rm -f ${tmpldif}

fi

USERHOME=$( /usr/sbin/crx_get_home.sh ${U} )
mkdir -m 700 -p $USERHOME/{Export,Import}
chown ${U} $USERHOME/{Export,Import}

