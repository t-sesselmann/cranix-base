#!/bin/bash

name=$1
ip=$2
nip=$3
if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
        echo "usage $@ name oldip newip [ domain ]"
        exit 1
fi
CRANIX_DOMAIN=$4
if [ -z "${CRANIX_DOMAIN}" ]; then
        . /etc/sysconfig/cranix
fi


passwd=$( grep de.cranix.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.dao.User.Register.Password=//' )

samba-tool dns update localhost $CRANIX_DOMAIN $name  A $ip $nip  -U register%"$passwd"
if [ $? != 0 ]; then
   abort
fi

