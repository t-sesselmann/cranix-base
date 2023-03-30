#!/bin/bash
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
ACTION=$1

case $ACTION in
	check-and-fix)
		/usr/share/cranix/tools/check-and-fix
	;;
	update)
		/usr/sbin/crx_update.sh
	;;
	reboot)
		/usr/bin/systemctl reboot
	;;
	shutdown)
		/usr/bin/systemctl poweroff
	;;
esac
