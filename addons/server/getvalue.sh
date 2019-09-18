#!/bin/bash

case $1 in
        listActions)
                ACTIONS="update shutdown reboot"
		echo -n $ACTIONS
                ;;
        listKeys)
                echo -n "version systemLoad listUpdate"
                ;;
        version)
		/usr/bin/rpm -q --qf "%{VERSION}-%{RELEASE}" oss-base
                ;;
	systemLoad)
		cat /proc/loadavg
		;;
	listUpdate)
		zypper lu
esac


