#!/bin/bash

IFS=$'\n'
for cn in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/class )
do
    g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
    i="/home/groups/$g"
    /bin/mkdir -p  "$i"
    gid=`/usr/sbin/oss_get_gidNumber.sh "$cn"`
    if [ "$gid" ]
    then
        chgrp -R $gid  "$i"
        /usr/bin/setfacl -P -R -b "$i"
        find "$i" -type d -exec /bin/chmod o-t,g+rwx {}  \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g::rwx {} \;
        echo "Repairing $i"
    else
       echo "Class $cn do not exists. Can not repair $i"
    fi
done
IFS=$'\n'
for cn in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/workgroup )
do
    g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
    i="/home/groups/$g"
    /bin/mkdir -p  "$i"
    gid=`/usr/sbin/oss_get_gidNumber.sh "$cn"`
    if [ "$gid" ]
    then
        chgrp -R $gid  "$i"
        /usr/bin/setfacl -P -R -b "$i"
        find "$i" -type d -exec /bin/chmod o-t,g+rwx {}  \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g::rwx {} \;
        echo "Repairing $i"
    else
       echo "Class $cn do not exists. Can not repair $i"
    fi
done

if [ -e /usr/share/oss/tools/custom_reset_groups.sh ]; then
        /usr/share/oss/tools/custom_reset_groups.sh
fi

