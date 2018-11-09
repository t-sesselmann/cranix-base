#!/bin/bash
# Fix the workstation users. It is neccessary for some AD stuff.

if [ -e "/var/adm/oss/update-4.0-07" ]
then
echo "Patch 4.0-07 already installed"
        exit 0
fi

for uid in $( oss_api.sh GET users/uidsByRole/workstations )
do
tmpldif=$( mktemp /tmp/fixwsXXXXXXXX )
        /usr/sbin/oss_get_dn.sh $uid > $tmpldif
        echo "changetype: modify
replace: userWorkstations
userWorkstations: ${SCHOOL_NETBIOSNAME},$uid" >> $tmpldif
        ldbmodify  -H /var/lib/samba/private/sam.ldb $tmpldif
done

touch /var/adm/oss/update-4.0-07

