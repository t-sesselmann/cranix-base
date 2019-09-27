#!/bin/bash
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#
# Change the efi boot image in dhcpd
sed -i s#elilo.efi#efi/grub.efi# /etc/dhcpd.conf
sed -i s#elilo.efi#efi/grub.efi# /usr/share/oss/templates/dhcpd.conf

# Change to kde
sed -i '/^DISPLAYMANAGER=.*/d'             /etc/sysconfig/displaymanager
sed -i 's/DEFAULT_WM=.*/DEFAULT_WM="kde"/' /etc/sysconfig/windowmanager

# Remove xfce packages
zypper -n rm $( rpm -qa "*xfce*" )
sed -i 's/#.*solver.allowVendorChange.*$/solver.allowVendorChange = true/' /etc/zypp/zypp.conf
sed -i 's#OSS/4.0.1$#OSS/4.1#' /etc/zypp/repos.d/OSS.repo
sed -i 's#OSS/4.0.1#OSS/4.1#'  /etc/zypp/credentials.cat

gpasswd -d root lp
sed -i 's/SystemGroup root lp/SystemGroup root/' /etc/cups/cups-files.conf
zypper ref
zypper --no-gpg-checks --gpg-auto-import-keys -n dup --auto-agree-with-licenses --no-recommends
zypper -n install --no-recommends sddm
zypper -n install patterns-kde-kde_plasma

# Adapt the destkop icons
cp /etc/skel/Desktop/* /root/Desktop/
tar xf /usr/share/oss/setup/templates/needed-files-for-root.tar -C /root/

systemctl restart samba
# Since 4.1 we have OUs
# We have to create it and move the users into the corresponding OU

for ROLE in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/primary )
do
	samba-tool ou create OU=${ROLE}
	for U in $( /usr/sbin/oss_api.sh GET users/uidsByRole/${ROLE} )
	do
		samba-tool user move ${U} OU=${ROLE}
	done
done
reboot
