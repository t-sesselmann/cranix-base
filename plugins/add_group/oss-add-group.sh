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


name=''
description=''
type=''
mail=''

while read a
do
  b=${a/:*/}
  c=${a/$b: /}
  case $b in
    name)
      name="${c}"
    ;;
    description)
      description="${c}"
    ;;
    type)
      type="${c}"
    ;;
    mail)
      mail="${c}"
    ;;
  esac
done

echo "name:        $name"
echo "description: $description"
echo "type:        $type"
echo "mail:        $mail"
#exit

params=''
if [ "$mail" ]; then
    params="--mail-address=\"$mail\""
fi

samba-tool group add "$name" --description="$description" $params


#create diredtory and set permission
nameLo=`echo "$name" | tr "[:upper:]" "[:lower:]"`
gdir=${SCHOOL_HOME_BASE}/groups/${nameLo}
gidnumber=`wbinfo -n $name | awk '{print "wbinfo -S "$1}'| bash`

mkdir -p -m 3770 $gdir
chgrp $gidnumber $gdir
setfacl -d -m g::rwx $gdir

