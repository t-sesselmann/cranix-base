#!/bin/bash
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
ACTION=$1
case $ACTION in
	migrate-to-4-1)
		/sbin/startproc -l /var/log/OSS-MIGRATE-TO-4-1.log /usr/share/oss/tools/migrate-to-4-1.sh
	;;
	reboot)
		/usr/bin/systemctl reboot
	;;
	shutdown)
		/usr/bin/systemctl poweroff
	;;
esac
