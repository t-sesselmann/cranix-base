#!/bin/bash

. /etc/sysconfig/cranix

samba-tool domain passwordsettings set --complexity=off
for uid in $( crx_api.sh GET users/uidsByRole/workstations )
do
   samba-tool user setpassword $uid --newpassword=$uid
done
if [ "${CRANIX_CHECK_PASSWORD_QUALITY}" = "yes" ]; then
   samba-tool domain passwordsettings set --complexity=on
fi

