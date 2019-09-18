#!/bin/bash

case $1 in
        listActions)
                ACTIONS="listUpdate update shutdown reboot"
		echo -n $ACTIONS
                ;;
        listKeys)
                echo -n "version systemLoad"
                ;;
        version)
		/usr/bin/rpm -q --qf "%{VERSION}-%{RELEASE}" oss-base
                ;;
	systemLoad)
		cat /proc/loadavg
esac


