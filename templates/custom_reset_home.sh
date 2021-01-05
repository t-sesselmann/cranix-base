#!/bin/bash
# Copyright (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu> Nürnberg, Germany.  All rights reserved.

. /etc/sysconfig/cranix

gidTeachers=$( /usr/sbin/crx_get_gidNumber.sh teachers )
IFS=$'\n'
for cn in $( /usr/sbin/crx_api_text.sh GET groups/text/byType/class )
do
    g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
    i="/home/groups/$g"
    /bin/mkdir -p  "$i"
    gid=`/usr/sbin/crx_get_gidNumber.sh "$cn"`
    if [ "$gid" ]
    then
        chgrp -R $gidTeachers  "$i"
        /usr/bin/setfacl -P -R -b "$i"
        find "$i" -type d -exec /usr/bin/chmod o-t,g+rwx {} \;
        find "$i" -type d -exec /usr/bin/setfacl -m g:$gidTeachers:rwx {} \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g:$gidTeachers:rwx {} \;
        find "$i" -type d -exec /usr/bin/setfacl -m g:$gid:rx {} \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g:$gid:rx {} \;
        echo "Repairing $i"
    else
       echo "Class $cn do not exists. Can not repair $i"
    fi
done


