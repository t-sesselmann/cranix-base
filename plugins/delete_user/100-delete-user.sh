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

surName=''
givenName=''
role=''
uid=''
password=''
rpassword='no'
mpassword='no'
groups=""

abort() {
        TASK=$( uuidgen -t )
	mkdir -p /var/adm/oss/opentasks/
        echo "delete_user" > /var/adm/oss/opentasks/$TASK
        echo "uid: $uid" >> /var/adm/oss/opentasks/$TASK
        echo "password: $password" >> /var/adm/oss/opentasks/$TASK
        echo "surName: $surName" >> /var/adm/oss/opentasks/$TASK
        echo "givenName: $givenName" >> /var/adm/oss/opentasks/$TASK
        echo "role: $role" >> /var/adm/oss/opentasks/$TASK
        exit 1
}

while read a
do
  b=${a/:*/}
  if [ "$a" != "${b}:" ]; then
     c=${a/$b: /}
  else
     c=""
  fi
  case $b in
    surName)
      surName="${c}"
    ;;
    givenName)
      givenName="${c}"
    ;;
    uid)
      uid="${c}"
    ;;
    role)
      role="${c}"
      sysadmin="${c}"
    ;;
  esac
done

echo "uid:       $uid"

if [ -z "$uid" ]; then
   echo "ERROR You have to define an uid."
   exit 4;
fi

HOMEDIR=$( /usr/sbin/oss_get_home.sh $uid )
UIDNUMBER=$(  /usr/sbin/oss_get_uidNumber.sh $uid )
# delete logon script
if [ -e /var/lib/samba/netlogon/$uid.bat ]; then
   rm  /var/lib/samba/netlogon/$uid.bat 
fi

nice -19 /usr/share/oss/tools/del_user_files --uid=$uid --uidnumber=$UIDNUMBER --startpath=${SCHOOL_HOME_BASE} --homedir=${HOMEDIR} &

# delete user
samba-tool user delete "$uid"

if [ $? != 0 ]; then
   abort
fi
rm ${SCHOOL_HOME_BASE}/${SCHOOL_WORKGROUP}/$uid


