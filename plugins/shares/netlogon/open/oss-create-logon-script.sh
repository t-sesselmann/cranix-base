#!/bin/bash

U=$1
I=$2
a=$3
m=$4
R=$5

. /etc/sysconfig/schoolserver

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

if [ -x /usr/share/oss/tools/custom_create_logon_script.sh ]; then
	/usr/share/oss/tools/custom_create_logon_script.sh ${U} ${I} ${a} ${m} ${R} ${role} 
fi

if [ -e /usr/share/oss/templates/copy_and_run_rem_printers ]; then
	cat /usr/share/oss/templates/copy_and_run_rem_printers >> /var/lib/samba/sysvol/$R/scripts/${U}.bat
fi

if [ ${SCHOOL_MOVE_PROFILE_TO_HOME} = "yes" -a ${SCHOOL_TEACHER_OBSERV_HOME} = "no"  ]; then
	cat /usr/share/oss/templates/login-profile-move-registy-patch >> /var/lib/samba/sysvol/$R/scripts/${U}.bat
	userHome=$( oss_get_home.sh ${U} )
        install -o ${U} -m 700 -d ${userHome}/{Documents,Downloads,Favorites,Pictures,WinDesktop,Videos,Music}
else 
	cat /usr/share/oss/templates/login-profile-move-back-registy-patch >> /var/lib/samba/sysvol/$R/scripts/${U}.bat
fi

defaultPrinter=$( oss_api.sh GET devices/byIP/$I/defaultPrinter )
if [ "$defaultPrinter" ]; then
        printf "rundll32 printui.dll,PrintUIEntry /q /in /n \134\\printserver\\$defaultPrinter /j\"Default $defaultPrinter\"\r\n" >> /var/lib/samba/sysvol/$R/scripts/${U}.bat;
        printf "rundll32 printui.dll,PrintUIEntry /y /n \134\\printserver\\$defaultPrinter /j\"Default $defaultPrinter\"\r\n"     >> /var/lib/samba/sysvol/$R/scripts/${U}.bat;
fi
for printer in $( oss_api.sh GET devices/byIP/$I/availablePrinters )
do
        printf "rundll32 printui.dll,PrintUIEntry /q /in /n \134\\printserver\\$printer /j\"$printer\"\r\n" >> /var/lib/samba/sysvol/$R/scripts/${U}.bat;
done


chown ${U} /var/lib/samba/sysvol/$R/scripts/${U}.bat
setfacl -m m::rwx /var/lib/samba/sysvol/$R/scripts/${U}.bat

