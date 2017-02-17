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


changetype=""
group=""
user=""

while read a
do
  b=${a/:*/}
  c=${a/$b: /}
  case $b in
    changetype)
      surname="${c}"
    ;;
    group)
      surname="${c}"
    ;;
    user)
      surname="${c}"
    ;;
  esac
done

samba-tool group $changetype $group $user

