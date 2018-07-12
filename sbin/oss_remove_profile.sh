#!/bin/bash
. /etc/sysconfig/schoolserver
uid=$1

for i in ${SCHOOL_HOME_BASE}/profiles/$uid.V*
do
    if [ -e "$i" ]
    then
        rm -rf $i
    fi
done
