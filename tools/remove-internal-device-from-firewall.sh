#!/bin/bash
extdev=$( ip route | gawk '/default/ {  print $5 }' )
for dev in $( firewall-cmd --zone=external --list-interfaces )
do
        if [ ${dev} != ${extdev} ]; then
                firewall-cmd --zone=external --remove-interface=${dev}
        fi
done
