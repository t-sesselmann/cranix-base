#!/bin/bash
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

case $ACTION in
	migrateTo4.1)
		/usr/share/oss/tools/migrate-to-4-1.sh
	;;
	reboot)
		/usr/bin/systemctl reboot
	;;
	shutdown)
		/usr/bin/systemctl poweroff
	;;
esac
