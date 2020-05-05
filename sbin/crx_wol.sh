#!/bin/bash

MAC=$1
IP=$2

. /etc/sysconfig/dhcpd

if  [ -e /usr/bin/wol ]
then
	/usr/bin/wol -i $IP $MAC
fi

if [ -e /sbin/ether-wake ]
then
        for i in $DHCPD_INTERFACE
        do
                /sbin/ether-wake -i $i $MAC
        done
fi

