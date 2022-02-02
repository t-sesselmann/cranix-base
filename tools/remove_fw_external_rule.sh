#!/bin/bash -x

echo "$1"  >> /tmp/remove-rich-rule
echo "===" >> /tmp/remove-rich-rule

/usr/bin/firewall-cmd --zone=external --remove-rich-rule="$1"  >> /tmp/remove-rich-rule
/usr/bin/firewall-cmd --permanent --zone=external --remove-rich-rule="$1" >> /tmp/remove-rich-rule

