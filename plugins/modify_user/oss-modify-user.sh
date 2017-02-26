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

abort() {
	TASK=$( uuidgen -t )
	echo "modify_user" > /var/adm/oss/opentasks/$TASK
	echo "uid:       $uid" >> /var/adm/oss/opentasks/$TASK
	echo "password:  $password" >> /var/adm/oss/opentasks/$TASK
	echo "surname:   $surname" >> /var/adm/oss/opentasks/$TASK
	echo "givenname: $givenname" >> /var/adm/oss/opentasks/$TASK
	echo "role:      $role" >> /var/adm/oss/opentasks/$TASK
	exit 1
}

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

role=${role/,*/} #Remove sysadmins
sysadmin=${sysadmin/$role/}


if [ $mpassword != "no" ]; then
   ADDPARAM=" --must-change-at-next-login"
fi

DN=$( /usr/bin/ldbsearch  -H /var/lib/samba/private/sam.ldb uid=$uid dn | grep dn: | sed 's/dn: //' )
b=${DN/CN=Users,*/}
BASE=${DN/$b/}
NEWDN="CN=$givenname $surname,$BASE"
/usr/bin/ldbrename -H /var/lib/samba/private/sam.ldb "$DN" "$NEWDN"
if [ $? != 0 ]; then
   abort
fi

FILE=$( mktemp /tmp/modify-user-XXXXXXXX )
echo "dn: $NEWDN
givenName: $givenname
sn: $surname" > $FILE

ldbmodify  -H /var/lib/samba/private/sam.ldb $FILE
if [ $? != 0 ]; then
   rm -f $FILE
   abort
fi
rm -f $FILE

