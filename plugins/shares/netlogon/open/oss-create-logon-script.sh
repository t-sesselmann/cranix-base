#!/bin/bash

U=$1
I=$2
a=$3
m=$4
R=$5


role=$( oss_api_text.sh GET users/byUid/$U/role )
mkdir -p /var/lib/samba/sysvol/$R/scripts
setfacl -m g:users:rx /var/lib/samba/sysvol/
setfacl -m g:users:rx /var/lib/samba/sysvol/$R/
setfacl -m g:users:rx /var/lib/samba/sysvol/$R/scripts/
if [ -e /usr/share/oss/templates/login-${role}.bat ]; then
	cp /usr/share/oss/templates/login-${role}.bat /var/lib/samba/sysvol/$R/scripts/${U}.bat
else
	cp /usr/share/oss/templates/login-default.bat /var/lib/samba/sysvol/$R/scripts/${U}.bat
fi
chown ${U} /var/lib/samba/sysvol/$R/scripts/${U}.bat
setfacl -m m::rwx /var/lib/samba/sysvol/$R/scripts/${U}.bat

