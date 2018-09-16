#!/bin/bash
# (c) 2017 Péter Varkoly <peter@varkoly.de> - all rights reserved

. /etc/sysconfig/schoolserver

user=$1
mkdir -m 500 -p $SCHOOL_HOME_BASE/groups/LINKED/$user/
chown $user $SCHOOL_HOME_BASE/groups/LINKED/$user/
rm -f $SCHOOL_HOME_BASE/groups/LINKED/$user/*

for GROUP in  $( oss_api_text.sh GET users/byUid/$user/groups )
do
    g=$( echo $GROUP|tr '[:lower:]' '[:upper:]' )
    if [ -d "$SCHOOL_HOME_BASE/groups/$g" ]
    then
        ln -s "$SCHOOL_HOME_BASE/groups/$g" "$SCHOOL_HOME_BASE/groups/LINKED/$user/$g"
    fi
done

userHome=$( /usr/sbin/oss_get_home.sh $user )
if [ ! -e $userHome/GROUPS ]; then
        ln -s $SCHOOL_HOME_BASE/groups/LINKED/$user $userHome/GROUPS
fi
if [ ! -e $userHome/ALL ]; then
        ln -s $SCHOOL_HOME_BASE/all $userHome/ALL
fi

