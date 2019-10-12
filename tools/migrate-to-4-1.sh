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

for i in $( grep -l 42.3 /etc/zypp/repos.d/*repo )
do
	if [ -e "$i" ]; then
		sed -i "s/42.3/15.1/" $i
	fi
done

gpasswd -d root lp
sed -i 's/SystemGroup root lp/SystemGroup root/' /etc/cups/cups-files.conf

rpm -e --nodeps  $( rpm -qa "python-*" )

zypper ref
if ! zypper --no-gpg-checks --gpg-auto-import-keys -n dup --auto-agree-with-licenses --no-recommends
then
	echo "An error accoured during the installation. Contact the support."
	echo "An error accoured during the installation. Contact the support!" > /var/adm/oss/migration-4.1-error
	exit 1
fi
zypper -n install --no-recommends sddm
zypper -n install patterns-kde-kde_plasma

#remove some not used packages
rpm -e python2-salt
rpm -e $( rpm -qa "python2*" ) python-html5lib  python-xhtml2pdf python-singledispatch python-backports.functools_lru_cache command-not-found

# Adapt the destkop icons
cp /etc/skel/Desktop/* /root/Desktop/
tar xf /usr/share/oss/setup/templates/needed-files-for-root.tar -C /root/

# Adapt samba
cp /usr/share/fillup-templates/sysconfig.samba /etc/sysconfig/samba
rm /etc/sysconfig/samba-printserver
cp /usr/share/oss/setup/templates/samba-printserver.service  /usr/lib/systemd/system/samba-printserver.service
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

passwd=$( grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//' )
net ADS JOIN -s /etc/samba/smb-printserver.conf -U register%${passwd}
echo "Migration to OSS4-1 was successfull." > /var/adm/oss/migration-4.1-successfull

#Reboot the system
reboot
