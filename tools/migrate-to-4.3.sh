#!/bin/bash
sed -i 's/4.2/4.3/g' /etc/zypp/repos.d/CRANIX.repo
sed -i 's/4.2/4.3/g' /etc/zypp/credentials.cat
sed -i 's/oss_/crx_/g' /etc/sysconfig/cranix
sed -i 's/cranix_get_screenshots/crx_get_screenshots/' /etc/sysconfig/cranix
sed -i 's/samba /samba-ad /' /etc/sysconfig/cranix
sed -i 's/solver.dupAllowVendorChange.*$/solver.dupAllowVendorChange = true/' /etc/zypp/zypp.conf
zypper ref
DATE=$( /usr/share/cranix/tools/crx_date.sh )
zypper --no-gpg-checks --gpg-auto-import-keys -n dup --auto-agree-with-licenses  2>&1 | tee /var/log/CRANIX-UPDATE-$DATE
systemctl enable samba-ad
systemctl start samba-ad
sleep 600
/sbin/reboot
