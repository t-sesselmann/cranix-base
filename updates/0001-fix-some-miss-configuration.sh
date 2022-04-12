#!/bin/bash

. /etc/sysconfig/cranix
sed -i s/en_DE/de_DE/ /root/.config/plasma-locale-settings.sh
if [ ! -e /usr/share/cranix/templates/password.html ]; then
	sed "s/SCHOOLNAME/${CRANIX_NAME}/" /usr/share/cranix/templates/password.html.in > /usr/share/cranix/templates/password.html
fi
if [ ! -e /srv/salt/ntp_conf.sls -a ! -e /srv/salt/win_ntp.sls ]; then
	/usr/share/cranix/setup/scripts/setup-chrony.sh
fi
if [ -z "$( grep "interface: ${CRANIX_SERVER}" /etc/salt/master.d/crx.conf )" ]; then
	echo "#Listen only on the admin interface" >> /etc/salt/master.d/crx.conf
	echo "interface: ${CRANIX_SERVER}" >> /etc/salt/master.d/crx.conf
	/usr/bin/systemctl restart salt-master crx_salt_event_watcher
fi
if [ ! -e /var/log/crx-update/CRANIX_MAINTAIN_ADHOC_ROOM_FOR_CLASSES ]; then
	echo "Reset CRANIX_MAINTAIN_ADHOC_ROOM_FOR_CLASSES"
	sed -i 's/CRANIX_MAINTAIN_ADHOC_ROOM_FOR_CLASSES=.*$/CRANIX_MAINTAIN_ADHOC_ROOM_FOR_CLASSES="no"/' /etc/sysconfig/cranix
	touch /var/log/crx-update/CRANIX_MAINTAIN_ADHOC_ROOM_FOR_CLASSES
fi


