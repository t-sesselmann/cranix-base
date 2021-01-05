#!/bin/bash
#
# Copyright (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu> Nürnberg, Germany.  All rights reserved.
#

if [ ! -e /etc/sysconfig/cranix ]; then
   echo "ERROR This ist not an CRANIX."
   exit 1
fi

. /etc/sysconfig/cranix

if [ -z "${CRANIX_HOME_BASE}" ]; then
   echo "ERROR CRANIX_HOME_BASE must be defined."
   exit 2
fi

if [ ! -d "${CRANIX_HOME_BASE}" ]; then
   echo "ERROR CRANIX_HOME_BASE must be a directory and must exist."
   exit 3
fi

abort() {
        TASK="add_group-$( uuidgen -t )"
        mkdir -p /var/adm/cranix/opentasks/
        echo "name: $name" >> /var/adm/cranix/opentasks/$TASK
        echo "password: $password" >> /var/adm/cranix/opentasks/$TASK
        echo "description: $description" >> /var/adm/cranix/opentasks/$TASK
        echo "groupType: $groupType" >> /var/adm/cranix/opentasks/$TASK
        if [ "$mail" ]; then
                echo "mail: $mail" >> /var/adm/cranix/opentasks/$TASK
        fi
        exit 1
}


name=''
description=''
groupType=''
mail=''

while read a
do
  b=${a/:*/}
  if [ "$a" != "${b}:" ]; then
     c=${a/$b: /}
  else
     c=""
  fi
  case $b in
    name)
      name="${c}"
    ;;
    description)
      description="${c}"
    ;;
    grouptype)
      groupType="${c}"
    ;;
    mail)
      mail="${c}"
    ;;
  esac
done

if [ "$groupType" != "class" ]; then
   exit
fi

name=`echo "$name" | tr "[:lower:]" "[:upper:]"`

echo "name:        $name"
echo "description: $description"
echo "groupType:   $groupType"
echo "mail:        $mail"

gidTeachers=$( /usr/sbin/crx_get_gidNumber.sh teachers )
gidNumber=$( gid=`/usr/sbin/crx_get_gidNumber.sh "$name" )
#gidNumber=$( /usr/share/cranix/tools/get_next_id )

#adapt the directory permissions:
#teachers have full righth
#other users can only read
gdir="${CRANIX_HOME_BASE}/groups/${name}"

mkdir -p -m 0770 "$gdir"
chgrp $gidTeachers "$gdir"
setfacl -m g:$gidTeachers:rwx "$gdir"
setfacl -d -m g:$gidTeachers:rwx "$gdir"
setfacl -m g:$gidNumber:rx "$gdir"
setfacl -d -m g:$gidNumber:rx "$gdir"

