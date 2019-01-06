#!/bin/bash
# Fix the workstation users. It is neccessary for some AD stuff.

if [ -e "/var/adm/oss/update-4.0-11" ]
then
echo "Patch 4.0-11 already installed"
        exit 0
fi

sed -i 's/^SCHOOL_MONITOR_SERVICES=.*/SCHOOL_MONITOR_SERVICES="amavis apache2 cups dhcpd ntpd oss-api oss_get_screenshots oss_salt_event_watcher postfix salt-master samba squid"/'  /etc/sysconfig/schoolserver

touch /var/adm/oss/update-4.0-11

