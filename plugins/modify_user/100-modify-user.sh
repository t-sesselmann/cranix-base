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
uid=''
password=''
rpassword='no'
mpassword='no'
groups=""
fsQuota=0
msQuota=0

abort() {
	TASK="modify_user-$( uuidgen -t )"
	mkdir -p /var/adm/oss/opentasks/
	echo "uid: $uid"             >> /var/adm/oss/opentasks/$TASK
	echo "password: $password"   >> /var/adm/oss/opentasks/$TASK
	echo "mpassword: $mpassword" >> /var/adm/oss/opentasks/$TASK
	echo "surName: $surName"     >> /var/adm/oss/opentasks/$TASK
	echo "givenName: $givenName" >> /var/adm/oss/opentasks/$TASK
	echo "fsQuota: $fsQuota"     >> /var/adm/oss/opentasks/$TASK
        echo "msQuota: $msQuota"     >> /var/adm/oss/opentasks/$TASK
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
      msQuota=$((msQuota*1024))
    ;;
  esac
done

#Set fsquota
/usr/sbin/oss_set_quota.sh $uid $fsQuota

#Set mailsystem quota
/usr/sbin/oss_set_mquota.pl $uid $msQuota

if [ "$surName" -a "$givenName" ]
then

DN=$( /usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb uid=$uid dn | grep dn: | sed 's/dn: //' )

FILE=$( mktemp /tmp/modify-user-XXXXXXXX )
echo "dn: $DN
changetype: modify
replace: givenName
givenName: $givenName
-
replace: sn
sn: $surName" > $FILE

ldbmodify  -H /var/lib/samba/private/sam.ldb $FILE
if [ $? != 0 ]; then
   rm -f $FILE
   abort
fi
rm -f $FILE

fi

if [ "$mpassword" != "no" ]; then
    ADDPARAM="--must-change-at-next-login"
fi

if [ "$password" ]; then
    samba-tool user setpassword $uid --newpassword="$password" $ADDPARAM
fi

