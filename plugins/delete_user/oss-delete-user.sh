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
  c=${a/$b: /}
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

FILE=`mktemp /tmp/oss_del_user_filesXXX`
DATUM=`/usr/share/oss/tools/oss_date.sh`

HOMEDIR=$( /usr/sbin/oss_get_home.sh $uid )
#delete home dir and profile dirs
if [ -d ${HOMEDIR} ]; then
    tar czf /home/archiv/$uid-$DATUM.tgz $HOMEDIR
    rm -r $HOMEDIR
fi

if [ -d ${SCHOOL_HOME_BASE}/profiles/$uid ]; then
   rm -r ${SCHOOL_HOME_BASE}/profiles/$uid
fi

# delete logon script
if [ -e /var/lib/samba/netlogon/$uid.bat ]; then
   rm  /var/lib/samba/netlogon/$uid.bat 
fi

UIDNUMBER=$(  /usr/sbin/oss_get_uidNumber.sh $uid )
for i in $SCHOOL_SEARCH_FOR_DELETE
do
        test -d $SCHOOL_HOME_BASE/$i || continue;
        #Find directories owned by this user
        find $SCHOOL_HOME_BASE/$i -type d -uid $UIDNUMBER -printf "rm -fr '%p'\n" > $FILE
        . $FILE
        #Find files owned by this user
        find $SCHOOL_HOME_BASE/$i -type f -uid $UIDNUMBER -printf "rm -f  '%p'\n" > $FILE
        . $FILE
done
rm $FILE

# delete user
samba-tool user delete "$uid"

if [ $? != 0 ]; then
   abort
fi


