#!/bin/bash

while /bin/true
do
        CLIENTS=$( oss_api_text.sh GET devices/allUsedDevices/1 )
        echo $CLIENTS
        salt --async -L $CLIENTS  cmd.run "C:\\Windows\\ClientControl\\tools\\GetScreenShot.exe C:\\bla" &> /dev/null
        sleep 1
        salt --async -L $CLIENTS  cp.push "C:\\bla" &> /dev/null
        for i in $( echo $CLIENTS | sed 's/,/ /' )
        do
                if [ -e /var/cache/salt/master/minions/${i}/files/bla ]; then
                        mv /var/cache/salt/master/minions/${i}/files/bla /srv/www/admin/screenShots/${i}.png
                fi
        done
        sleep 4
done
