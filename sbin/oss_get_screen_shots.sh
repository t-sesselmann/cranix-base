#!/bin/bash

. /etc/sysconfig/schoolserver
mkdir -p /srv/www/admin/screenShots/
while /bin/true
do
        CLIENTS=$( oss_api_text.sh GET devices/allUsedDevices/1 )
	if [ "$SCHOOL_DEBUG" = "yes" ]; then
		echo $CLIENTS
	fi
        salt --async -L $CLIENTS  cmd.run "C:\\Windows\\ClientControl\\ClientControl.exe getScreenShot C:\\screenShot" &> /dev/null
        sleep 2
        salt --async -L $CLIENTS  cp.push "C:\\screenShot" &> /dev/null
	sleep 1
        for MINION in $( echo $CLIENTS | sed 's/,/ /g' )
        do
                if [ -e /var/cache/salt/master/minions/${MINION}/files/screenShot ]; then
			CLIENT=${MINION/.$SCHOOL_DOMAIN/}
                        mv /var/cache/salt/master/minions/${MINION}/files/screenShot /srv/www/admin/screenShots/${CLIENT}.png
                fi
        done
        sleep 1
done
