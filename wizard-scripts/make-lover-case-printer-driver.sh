#!/bin/bash

ADMINPW=$1
while ! smbclient -L printserver -U Administrator%"$ADMINPW"
do
	echo -n "Passwort des Administrators:"
	read ADMINPW
done

. /etc/sysconfig/schoolserver

for i in $( lpc status | grep ':$' | sed 's/://' )
do
	#Check if this printer is in the DB
	INDB=$( echo "select name from Printers where name='$i'" | mysql OSS )
	if [ -z "${INDB}" ]; then
		continue
	fi

	lower=$( echo $i | tr [:upper:] [:lower:] )
	if [ $lower != $i ];
       	then
		sed -i "s/${i}>/${lower}>/" /etc/cups/printers.conf
		mv /etc/cups/ppd/$i.ppd /etc/cups/ppd/${lower}.ppd
		systemctl restart cups
		sleep 2
		/usr/sbin/cupsaddsmb -v -H ${SCHOOL_PRINTSERVER} -U Administrator%"$ADMINPW" $lower
	fi
done
