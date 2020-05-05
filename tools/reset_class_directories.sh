#!/bin/bash

if [ -d "/home/classes" ]
then
        rm /home/classes/*/*
        rm -r /home/classes/*
        chmod 750 /home/classes/
else
        mkdir -m 750 /home/classes
fi
chown root:teachers /home/classes
chown root:teachers /home/students
setfacl -b /home/classes
chmod 751 /home/classes


for CLASS in $( /usr/sbin/crx_api_text.sh GET groups/text/byType/class )
do
        mkdir -p -m 750 /home/classes/$CLASS
        chown root:teachers /home/classes/$CLASS
done

for USER in  $( /usr/sbin/crx_api.sh GET users/uidsByRole/students )
do
        home=$( /usr/sbin/crx_get_home.sh ${USER} )
        chgrp -R teachers $home; chmod 2770 $home;
        find $home -type f -exec setfacl -b {} \;
        find $home -type d -exec setfacl -b {} \;
        find $home -type f -exec chmod g+rw {} \;
        find $home -type d -exec chmod 2770 {} \;
        find $home -type d -exec setfacl -d -m g::rwx {} \;
        for CLASS in $( /usr/sbin/crx_api_text.sh GET users/text/${USER}/classes )
        do
                ln -s $home /home/classes/$CLASS/$USER
        done
        echo "$USER DONE"
done

