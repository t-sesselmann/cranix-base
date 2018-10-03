#!/bin/bash
#
# Copyright (c) 2017 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#

if [ ! -e /etc/sysconfig/schoolserver ]; then
   echo "ERROR This ist not an OSS."
   exit 1
fi

. /etc/sysconfig/schoolserver

if [ -z "${SCHOOL_HOME_BASE}" ]; then
   echo "ERROR SCHOOL_HOME_BASE must be defined."
   exit 2
fi

if [ ! -d "${SCHOOL_HOME_BASE}" ]; then
   echo "ERROR SCHOOL_HOME_BASE must be a directory and must exist."
   exit 3
fi

abort() {
        TASK="add_group-$( uuidgen -t )"
        mkdir -p /var/adm/oss/opentasks/
        echo "name: $name" >> /var/adm/oss/opentasks/$TASK
        echo "password: $password" >> /var/adm/oss/opentasks/$TASK
        echo "description: $description" >> /var/adm/oss/opentasks/$TASK
        echo "groupType: $groupType" >> /var/adm/oss/opentasks/$TASK
	if [ "$mail" ]; then
		echo "mail: $mail" >> /var/adm/oss/opentasks/$TASK
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
    groupType)
      groupType="${c}"
    ;;
    mail)
      mail="${c}"
    ;;
  esac
done

name=`echo "$name" | tr "[:lower:]" "[:upper:]"`

echo "name:        $name"
echo "description: $description"
echo "groupType:   $groupType"
echo "mail:        $mail"
#exit

params=''
if [ "$mail" ]; then
    params="--mail-address=\"$mail\""
fi

gidNumber=$( /usr/share/oss/tools/get_next_id )
samba-tool group add "$name" --description="$description" --gid-number=$gidNumber --nis-domain=${SCHOOL_WORKGROUP} $params

if [ $? != 0 ]; then
   abort
fi

#create diredtory and set permission
nameLo=`echo "$name" | tr "[:upper:]" "[:lower:]"`
gdir=${SCHOOL_HOME_BASE}/groups/${name}

mkdir -p -m 3770 "$gdir"
chgrp $gidNumber "$gdir"
setfacl -d -m g::rwx "$gdir"

if [ "$groupType" = "primary" ]; then
   mkdir -m 750 "${SCHOOL_HOME_BASE}/${nameLo}"
   chgrp $gidNumber "${SCHOOL_HOME_BASE}/${nameLo}"
fi

