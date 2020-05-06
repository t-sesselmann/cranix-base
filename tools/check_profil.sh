#!/bin/bash

user=$1
arch=$3
group=$( id -g $user &> /dev/null )

. /etc/sysconfig/cranix

#Win8 wants to create logon for the machine accounts too.
id $user &> /dev/null ||  exit 2

if [ ! -e $CRANIX_HOME_BASE/profile/$user/$arch ]; then
	mkdir -m 700 -p $CRANIX_HOME_BASE/profile/$user/$arch
	chown $user $CRANIX_HOME_BASE/profile/$user $CRANIX_HOME_BASE/profile/$user/$arch
fi
USERHOME=$( /usr/sbin/crx_get_home.sh $user )

if [ "${USERHOME/home/}" = "$USERHOME" ]; then
        echo "check_profil.sh error $user does not have homedirectory $USERHOME"
        exit 1
fi

MODE="700"

if [ "$group" = "501" -a "$CRANIX_TEACHER_OBSERV_HOME" = "yes" -a  "$CRANIX_MOVE_PROFILE_TO_HOME" = "yes" ]; then
	echo "CRANIX_TEACHER_OBSERV_HOME and CRANIX_MOVE_PROFILE_TO_HOME can not be set together to yes"
	exit 1
fi

# Die neuen Ordner werden, falls nicht vorhanden, angelegt
if [ "$CRANIX_MOVE_PROFILE_TO_HOME" = "yes" ]; then
	for i in Documents  Downloads  Favorites Music Pictures Videos
	do
		if [ ! -d $USERHOME/$i ]; then
			mkdir -m $MODE $USERHOME/$i
			chown $user:$group $USERHOME/$i
		fi
		if [ -d $CRANIX_HOME_BASE/profile/$user/$arch/$i ]; then
			mv $CRANIX_HOME_BASE/profile/$user/$arch/$i/* $USERHOME/$i/
			rm -r $CRANIX_HOME_BASE/profile/$user/$arch/$i/
		fi
	done
	if [ ! -d $USERHOME/WinDesktop ]; then
		mkdir -m $MODE $USERHOME/WinDesktop
		chown $user:$group $USERHOME/WinDesktop
	fi
	if [ -d $CRANIX_HOME_BASE/profile/$user/$arch/Desktop ]; then
		mv $CRANIX_HOME_BASE/profile/$user/$arch/Desktop/* $USERHOME/WinDesktop/
		rm -r $CRANIX_HOME_BASE/profile/$user/$arch/Desktop/
	fi
fi
