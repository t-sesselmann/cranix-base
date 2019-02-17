#!/bin/bash

. /etc/sysconfig/schoolserver

samba-tool domain passwordsettings set --complexity=off
for uid in $( oss_api.sh GET users/uidsByRole/workstations )
do
   samba-tool user setpassword $uid --newpassword=$uid
done
if [ "${SCHOOL_CHECK_PASSWORD_QUALITY}" = "yes" ]; then
   samba-tool domain passwordsettings set --complexity=on
fi

