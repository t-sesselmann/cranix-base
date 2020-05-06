#!/bin/bash
# (c) Péter Varkoly <peter@varkoly.de> - all rights reserved

. /etc/sysconfig/cranix

user=$1
mkdir -m 500 -p $CRANIX_HOME_BASE/groups/LINKED/$user/
chown $user $CRANIX_HOME_BASE/groups/LINKED/$user/
rm -f $CRANIX_HOME_BASE/groups/LINKED/$user/*

cd "$CRANIX_HOME_BASE/groups/LINKED/$user/"
IFS=$'\n'
for GROUP in  $( crx_api_text.sh GET users/byUid/$user/groups )
do
    g=$( echo $GROUP|tr '[:lower:]' '[:upper:]' )
    if [ -d "$CRANIX_HOME_BASE/groups/$g" ]
    then
        ln -s "$CRANIX_HOME_BASE/groups/$g"
    fi
done
unset IFS

userHome=$( /usr/sbin/crx_get_home.sh $user )
if [ -z "${userHome}" -o ${userHome/${CRANIX_HOME_BASE}/} = ${userHome} ]; then
	exit 1
fi
if [ ! -e $userHome/GROUPS ]; then
        ln -s $CRANIX_HOME_BASE/groups/LINKED/$user $userHome/GROUPS
fi
if [ ! -e $userHome/ALL -a -d $CRANIX_HOME_BASE/all ]; then
        ln -s $CRANIX_HOME_BASE/all $userHome/ALL
fi

