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


sureName=''
givenName=''
role=''
uid=''
password=''
rpassword='no'
mpassword='no'
groups=""
fsQuota=0
msQuota=0

abort() {
	TASK=$( uuidgen -t )
	echo "modify_user" > /var/adm/oss/opentasks/$TASK
	echo "uid: $uid" >> /var/adm/oss/opentasks/$TASK
	echo "password: $password" >> /var/adm/oss/opentasks/$TASK
	echo "mpassword: $mpassword" >> /var/adm/oss/opentasks/$TASK
	echo "sureName: $sureName" >> /var/adm/oss/opentasks/$TASK
	echo "givenName: $givenName" >> /var/adm/oss/opentasks/$TASK
	echo "role: $role" >> /var/adm/oss/opentasks/$TASK
	echo "fsQuota: $fsQuota" >> /var/adm/oss/opentasks/$TASK
        echo "msQuota: $msQuota" >> /var/adm/oss/opentasks/$TASK
	exit 1
}

while read a
do
  b=${a/:*/}
  c=${a/$b: /}
  case $b in
    sureName)
      sureName="${c}"
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
    password)
      password="${c}"
    ;;
    mpassword)
      mpassword="${c}"
    ;;
    fsQuota)
      fsQuota="${c}"
    ;;
    msQuota)
      msQuota="${c}"
    ;;
  esac
done

#Set fsquota
/usr/sbin/oss_set_quota.sh $uid $fsQuota

#TODO hande mailsystem quota

role=${role/,*/} #Remove sysadmins
sysadmin=${sysadmin/$role/}

if [ $mpassword != "no" ]; then
   ADDPARAM=" --must-change-at-next-login"
fi

DN=$( /usr/bin/ldbsearch  -H /var/lib/samba/private/sam.ldb uid=$uid dn | grep dn: | sed 's/dn: //' )
b=${DN/CN=Users,*/}
BASE=${DN/$b/}
NEWDN="CN=$givenName $sureName,$BASE"
/usr/bin/ldbrename -H /var/lib/samba/private/sam.ldb "$DN" "$NEWDN"
if [ $? != 0 ]; then
   abort
fi

FILE=$( mktemp /tmp/modify-user-XXXXXXXX )
echo "dn: $NEWDN
changetype: modify
replace: givenName
givenName: $givenName
-
replace: sn
sn: $sureName" > $FILE

ldbmodify  -H /var/lib/samba/private/sam.ldb $FILE
if [ $? != 0 ]; then
   rm -f $FILE
   abort
fi
rm -f $FILE


