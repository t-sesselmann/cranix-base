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
	/sbin/ether-wake -i $DHCPD_INTERFACE $MAC
fi

