#!/bin/bash

case $1 in
        listActions)
                ACTIONS="migrate-to-4-1 shutdown reboot"
		echo -n $ACTIONS
                ;;
        listKeys)
                echo -n "migrationState version systemLoad listUpdate"
                ;;
	migrationState)
		if [ -e /var/adm/oss/migration-4.1-error ]; then
			cat /var/adm/oss/migration-4.1-error
		elif [ -e /var/adm/oss/migration-4.1-success ]; then
			cat /var/adm/oss/migration-4.1-error
		else
			echo "Migration to 4-1 was not started."
		fi
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


