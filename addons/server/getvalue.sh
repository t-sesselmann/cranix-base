#!/bin/bash

case $1 in
        listActions)
                ACTIONS="update shutdown reboot check-and-fix"
		echo -n $ACTIONS
                ;;
        listKeys)
                echo -n "version systemLoad listUpdate"
                ;;
        version)
		/usr/bin/rpm -q --qf "%{VERSION}-%{RELEASE}" cranix-base
                ;;
	systemLoad)
		cat /proc/loadavg
		;;
	listUpdate)
		zypper lu
esac


