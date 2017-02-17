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

role=${role/,*/} #Remove sysadmins
sysadmin=${sysadmin/$role/}

skel="/etc/skel"

winprofile="\\\\schooladmin\\profiles\\$uid"
winhome="\\\\schooladmin\\$uid"
unixhome=${SCHOOL_HOME_BASE}/$uid

echo "uid:       $uid"
echo "password:  $password"
echo "surname:   $surname"
echo "givenname: $givenname"
echo "winhome:   $winhome"
echo "unixhome:  $unixhome"
echo "profile:   $profile"
echo "role:      $role"

if [ $mpassword != "no" ]; then
   ADDPARAM=" --must-change-at-next-login"
fi

samba-tool user create "$uid" "$password" \
				--username="$uid" \
				--uid="$uid" \
				--password="$password" \
				--surname="$surname" \
				--given-name="$givenname" \
				--home-drive="Z:" \
				--home-directory="$winhome" \
				--unix-home="$unixhome" \
				--profile-path="$winprofile" \
				--script-path="$uid.bat" $ADDPARAM

uidnumber=`wbinfo -n $uid  | awk '{print "wbinfo -S "$1}'| bash`
gidnumber=`wbinfo -n $role | awk '{print "wbinfo -S "$1}'| bash`


#create home diredtory and set permission
mkdir -p $unixhome
if [ "$SCHOOL_TEACHER_OBSERV_HOME" = "yes" -a "$role" = "students" ]; then
	chown -R $uidnumber:TEACHERS $unixhome
	chmod 0770 $unixhome
else
	chown -R $uidnumber:$gidnumber $unixhome
	chmod 0700 $unixhome
fi

#Create profiles directory
mkdir -m 700 -p ${SCHOOL_HOME_BASE}/profiles/$uid
chown $uidnumber  ${SCHOOL_HOME_BASE}/profiles/$uid

#add user to groups
samba-tool group addmembers "$role" "$uid"

if [ "$sysadmin" = ",sysadmins" ]; then
   samba-tool group addmembers "sysadmins" "$uid"
fi

