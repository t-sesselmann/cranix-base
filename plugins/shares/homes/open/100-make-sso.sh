#!/bin/bash

U=$1
I=$2
a=$3
m=$4
R=$5


oss_api.sh PUT devices/loggedInUsers/$I/$U

. /etc/sysconfig/schoolserver
role=$( oss_api_text.sh GET users/byUid/$U/role )

case "${role}" in
	workstations)
	;;
	students)
		if [ "${SCHOOL_ALLOW_STUDENTS_MULTIPLE_LOGIN}" = "no" ]; then
			DN=$( oss_get_dn.sh ${U} )
		fi
	;;
	*)
		if [ "${SCHOOL_ALLOW_MULTIPLE_LOGIN}" = "no" ]; then
			DN=$( oss_get_dn.sh ${U} )
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
