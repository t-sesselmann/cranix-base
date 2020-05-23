#!/bin/bash

. /etc/sysconfig/schoolserver
rpm -e --nodeps ntp
zypper -n install chrony

sed -i 's/^pool/#pool/' /etc/chrony.conf

echo "# CRANIX CHRONY CONF
pool 0.pool.ntp.org
ntpsigndsocket  /var/lib/samba/ntp_signd/
allow           ${SCHOOL_NETWORK}/${SCHOOL_NETMASK}
bindcmdaddress  ${SCHOOL_SERVER}
" > /etc/chrony.d/cranix.conf

if [ -d /usr/share/oss/templates/ ]; then
	echo "base:
  '*':
    - ntp_conf" > /usr/share/oss/templates/top.sls
else
	echo "base:
  '*':
    - ntp_conf" > /usr/share/cranix/templates/top.sls
fi
echo "ntp_conf:
  ntp.managed:
    - servers:
      - admin
" > /srv/salt/ntp_conf.sls

systemctl restart chronyd
systemctl enable chronyd
sleep 10
systemctl restart samba
oss_api.sh PUT softwares/saveState

