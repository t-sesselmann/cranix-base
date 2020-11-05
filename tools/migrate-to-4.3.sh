#!/bin/bash
sed -i 's/4.2/4.3/g' /etc/zypp/repos.d/CRANIX.repo
sed -i 's/4.2/4.3/g' /etc/zypp/credentials.cat
sed -i 's/solver.dupAllowVendorChange.*$/solver.dupAllowVendorChange = true/' /etc/zypp/zypp.conf
DATE=$( /usr/share/cranix/tools/crx_date.sh )
zypper --no-gpg-checks --gpg-auto-import-keys -n dup --auto-agree-with-licenses  2>&1 | tee /var/log/CRANIX-UPDATE-$DATE
systemctl enable samba-ad
systemctl start samba-ad
sleep 600
/sbin/reboot
