#!/bin/bash
extdev=$( grep -l ZONE=external /etc/sysconfig/network/ifcfg* )
extdev=${extdev/*ifcfg-/}
for dev in $( firewall-cmd --zone=external --list-interfaces )
do
        if [ ${dev} != ${extdev} ]; then
                firewall-cmd --zone=external --remove-interface=${dev}
        fi
done
