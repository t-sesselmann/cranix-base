#!/bin/bash
. /etc/sysconfig/schoolserver
CLIENT=$1
NEWIP=$2
OLDIP=$3

if [ -z ${NEWIP} -o -z ${CLIENT} ]; then
   echo
   echo "Usage oss_change_ip_for_host.sh <Hostname> <Newip> [ <Oldip> ]"
   echo 
   exit 1
fi
passwd=$( grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//' )

if [ -z $OLDIP ]; then
	OLDIP=$( host $CLIENT | gawk '{ print $4 }' )
fi
samba-tool dns delete localhost $SCHOOL_DOMAIN $CLIENT  A $OLDIP   -U register%"$passwd"
samba-tool dns add    localhost $SCHOOL_DOMAIN $CLIENT  A $NEWIP   -U register%"$passwd"

