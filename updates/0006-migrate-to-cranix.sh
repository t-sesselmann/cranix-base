#!/bin/bash

sed -i s#OSS/4.1#CRANIX/4.2# /etc/zypp/credentials.cat
sed -i 's/solver.dupAllowVendorChange*$/solver.dupAllowVendorChange = true/' /etc/zypp/zypp.conf
mv /etc/zypp/repos.d/OSS.repo /etc/zypp/repos.d/CRANIX.repo
sed -i s/OSS/CRANIX/ /etc/zypp/repos.d/CRANIX.repo
sed -i s/4.1/4.2/ /etc/zypp/repos.d/CRANIX.repo
sed s/SCHOOL_/CRANIX_/ /etc/sysconfig/schoolserver > /etc/sysconfig/cranix
mkdir -p /usr/share/cranix/templates/
rsync -aAv /usr/share/oss/templates/ /usr/share/cranix/templates/
sed -i s#oss/plugins#cranix/plugins# /etc/samba/smb.conf
sed -i s#oss/tools#cranix/tools# /etc/samba/smb.conf
sed -i s/oss_api.sh/crx_api.sh/ /etc/sysconfig/scripts/SuSEfirewall2-custom
if [ -e /etc/chrony.d/oss.conf ]; then
	mv /etc/chrony.d/oss.conf /etc/chrony.d/cranix.conf
fi
systemctl restart atd

echo "/usr/bin/zypper ref &>  /var/log/MIGRATE-TO-CRANIX-1.log
/usr/bin/zypper -n up &>  /var/log/MIGRATE-TO-CRANIX-2.log
/bin/rpm -e --nodeps OSS-release OSS-release-dvd &>  /var/log/MIGRATE-TO-CRANIX-3.log
/usr/bin/zypper -n install CRANIX-release CRANIX-release-dvd &>  /var/log/MIGRATE-TO-CRANIX-4.log
if [ ! -e /etc/chrony.d/cranix.conf ]; then
	/usr/share/cranix/setup/scripts/setup-chrony.sh
fi
" |  at "now + 20 minutes"

