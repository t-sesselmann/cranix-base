#!/bin/bash

name=$1
ip=$2
if [ -z "$1" -o -z "$2" ]; then
        echo "usage $@ name ip [ domain ]"
        exit 1
fi
CRANIX_DOMAIN=$3
if [ -z "${CRANIX_DOMAIN}" ]; then
        . /etc/sysconfig/cranix
fi


passwd=$( grep de.cranix.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.dao.User.Register.Password=//' )

samba-tool dns delete localhost $CRANIX_DOMAIN $name  A $ip   -U register%"$passwd"
if [ $? != 0 ]; then
   abort
fi
