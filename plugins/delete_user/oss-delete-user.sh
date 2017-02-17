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

surname=''
givenname=''
role=''
uid=''
password=''
rpassword='no'
mpassword='no'
groups=""


while read a
do
  b=${a/:*/}
  c=${a/$b: /}
  case $b in
    surname)
      surname="${c}"
    ;;
    givenname)
      givenname="${c}"
    ;;
    uid)
      uid="${c}"
    ;;
    role)
      role="${c}"
      sysadmin="${c}"
    ;;
    password)
      password="${c}"
    ;;
    mpassword)
      mpassword="${c}"
    ;;
  esac
done

echo "uid:       $uid"

if [ -z "$uid" ]; then
   echo "ERROR You have to define an uid."
   exit 4;
fi

# delete user
samba-tool user delete "$uid"


#delete home dir and profile dirs
if [ -d ${SCHOOL_HOME_BASE}/$uid ]; then
    rm -r ${SCHOOL_HOME_BASE}/$uid
fi

if [ -d ${SCHOOL_HOME_BASE}/profiles/$uid ]; then
   rm -r ${SCHOOL_HOME_BASE}/profiles/$uid
fi

# delete logon script
if [ -e /var/lib/samba/netlogon/$uid.bat ]; then
   rm  /var/lib/samba/netlogon/$uid.bat 
fi

