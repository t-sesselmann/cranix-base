#!/bin/bash

echo "$1"  >> /tmp/add-rich-rule
echo "===" >> /tmp/add-rich-rule

/usr/bin/firewall-cmd --zone=external --add-rich-rule="$1"
/usr/bin/firewall-cmd --permanent --zone=external --add-rich-rule="$1"

