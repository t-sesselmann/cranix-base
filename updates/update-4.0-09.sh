#!/bin/bash
# Fix the workstation users. It is neccessary for some AD stuff.

if [ -e "/var/adm/oss/update-4.0-09" ]
then
echo "Patch 4.0-09 already installed"
        exit 0
fi

WS=$( /usr/share/oss/tools/squidGuard.pl read | grep workstations )
if [ -z "${WS}" ]; then
	/usr/sbin/oss_api_text.sh GET groups/text/workstations/members | /usr/share/oss/tools/squidGuard.pl writeUserSource workstations
	echo "workstations:bad:false" | /usr/share/oss/tools/squidGuard.pl write
	echo "workstations:bad:false" | /usr/share/oss/tools/squidGuard.pl write
fi

touch /var/adm/oss/update-4.0-09

