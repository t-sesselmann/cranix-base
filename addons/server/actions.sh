#!/bin/bash
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

case $ACTION in
	listUpdates)
		zypper lu
	;;
	update)
		/usr/sbin/oss_update.sh
	;;
	reboot)
		/usr/bin/systemctl reboot
	;;
	shutdown)
		/usr/bin/systemctl poweroff
	;;
esac
