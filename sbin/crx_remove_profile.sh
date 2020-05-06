#!/bin/bash
. /etc/sysconfig/cranix
uid=$1

for i in ${CRANIX_HOME_BASE}/profiles/$uid.V*
do
    if [ -e "$i" ]
    then
        rm -rf $i
    fi
done
