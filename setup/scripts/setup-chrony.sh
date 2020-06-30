#!/bin/bash

. /etc/sysconfig/schoolserver
rpm -e --nodeps ntp
zypper -n install chrony

sed -i 's/^pool/#pool/' /etc/chrony.conf

echo "# OSS CHRONY CONF
pool de.pool.ntp.org
ntpsigndsocket  /var/lib/samba/ntp_signd/
allow           ${SCHOOL_NETWORK}/${SCHOOL_NETMASK}
bindcmdaddress  ${SCHOOL_SERVER}
" > /etc/chrony.d/oss.conf

systemctl restart chronyd
systemctl enable chronyd
sleep 5
systemctl restart samba
oss_api.sh PUT softwares/saveState

