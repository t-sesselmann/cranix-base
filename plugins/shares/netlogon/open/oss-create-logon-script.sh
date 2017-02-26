#!/bin/bash

U=$1
I=$2
a=$3
m=$4
R=$5


role=$( echo "select role from Users where uid='admin'" | mysql -u claxss -pcl8x77 OSS  | tail -n 1 )
mkdir -p /var/lib/samba/sysvol/$R/scripts
setfacl -m g:users:rx /var/lib/samba/sysvol/
setfacl -m g:users:rx /var/lib/samba/sysvol/$R/
setfacl -m g:users:rx /var/lib/samba/sysvol/$R/scripts/
cp /usr/share/oss/templates/login-${role}.bat.ini /var/lib/samba/sysvol/$R/scripts/${U}.bat
chown ${U} /var/lib/samba/sysvol/$R/scripts/tstudents.bat
setfacl -m m::rwx /var/lib/samba/sysvol/$R/scripts/tstudents.bat

