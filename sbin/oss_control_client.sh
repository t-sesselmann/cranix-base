#!/bin/bash

client=$1
action=$2

if [ -z "${client}" -o -z "${action}" ]; then
	echo ""
	echo "usage: oss_control_client.sh ClientName Action"
	echo ""
	echo "Actions: open close reboot shutdown wol logout unlockInput lockInput cleanUpLoggedIn"
	echo ""
	exit 1
fi
/usr/sbin/oss_api.sh PUT devices/byName/${client}/actions/${action}

