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
        TASK=$( uuidgen -t )
	mkdir -p /var/adm/oss/opentasks/
        echo "add_user" > /var/adm/oss/opentasks/$TASK
        echo "uid: $uid" >> /var/adm/oss/opentasks/$TASK
        echo "password: $password" >> /var/adm/oss/opentasks/$TASK
        echo "sureName: $sureName" >> /var/adm/oss/opentasks/$TASK
        echo "givenName: $givenName" >> /var/adm/oss/opentasks/$TASK
        echo "role: $role" >> /var/adm/oss/opentasks/$TASK
        echo "fsQuota: $fsQuota" >> /var/adm/oss/opentasks/$TASK
        echo "msQuota: $msQuota" >> /var/adm/oss/opentasks/$TASK
        exit 1
}

sureName=''
givenName=''
role=''
uid=''
password=''
rpassword='no'
mpassword='no'
fsQuota=0
msQuota=0
groups=""


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

role=${role/,*/} #Remove sysadmins
sysadmin=${sysadmin/$role/}

skel="/etc/skel"

winprofile="\\\\${SCHOOL_NETBIOSNAME}\\profiles\\$uid"
winhome="\\\\${SCHOOL_NETBIOSNAME}\\$uid"
unixhome=${SCHOOL_HOME_BASE}/$uid

echo "uid:       $uid"
echo "password:  $password"
echo "sureName:   $sureName"
echo "givenName: $givenName"
echo "winhome:   $winhome"
echo "unixhome:  $unixhome"
echo "profile:   $profile"
echo "role:      $role"

if [ $mpassword != "no" ]; then
   ADDPARAM=" --must-change-at-next-login"
fi

if [ "$role" = "workstations" ]; then
    samba-tool domain passwordsettings set --complexity=off
fi

samba-tool user create "$uid" "$password" \
				--username="$uid" \
				--uid="$uid" \
				--password="$password" \
				--surname="$sureName" \
				--given-name="$givenName" \
				--home-drive="Z:" \
				--home-directory="$winhome" \
				--unix-home="$unixhome" \
				--profile-path="$winprofile" \
				--script-path="$uid.bat" $ADDPARAM

if [ $? != 0 ]; then
   if [ "$role" = "workstations" ]; then
       samba-tool domain passwordsettings set --complexity=on
   fi
   abort
fi
if [ "$role" = "workstations" ]; then
    samba-tool domain passwordsettings set --complexity=on
fi

uidnumber=`wbinfo -n $uid  | awk '{print "wbinfo -S "$1}'| bash`
gidnumber=`wbinfo -n $role | awk '{print "wbinfo -S "$1}'| bash`


#create home diredtory and set permission
mkdir -p $unixhome
if [ "$SCHOOL_TEACHER_OBSERV_HOME" = "yes" -a "$role" = "students" ]; then
	chown -R $uidnumber:TEACHERS "$unixhome"
	chmod 0770 "$unixhome"
else
	chown -R $uidnumber:$gidnumber "$unixhome"
	chmod 0700 "$unixhome"
fi

#Create profiles directory
mkdir -m 700 -p ${SCHOOL_HOME_BASE}/profiles/$uid
chown $uidnumber  ${SCHOOL_HOME_BASE}/profiles/$uid

#add user to groups
samba-tool group addmembers "$role" "$uid"

if [ "$sysadmin" = ",sysadmins" ]; then
   samba-tool group addmembers "sysadmins" "$uid"
fi

#Workstation users password should not expire
if [ "$role" = "workstations" ]; then
	pdbedit -u $uid -c "[X]"
fi

#Set default quota
if [ -z "$fsQuota" ]; then
        fsQuota=$SCHOOL_FILE_QUOTA
        if [ $role = "teachers" ]; then
                fsQuota=$SCHOOL_FILE_TEACHER_QUOTA
        fi
fi

/usr/sbin/oss_set_quota.sh $uid $fsQuota
#TODO hande mailsystem quota

