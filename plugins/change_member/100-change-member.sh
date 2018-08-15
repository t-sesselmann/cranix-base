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


changeType=""
group=""
users=""

while read a
do
  b=${a/:*/}
  c=${a/$b: /}
  case $b in
    changeType)
      changeType="${c}"
    ;;
    group)
      group="${c}"
    ;;
    users)
      users="${c}"
    ;;
  esac
done

samba-tool group $changeType $group $users

