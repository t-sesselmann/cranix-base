#!/bin/bash
. /etc/sysconfig/schoolserver

abort() {
        TASK="add_device-$( uuidgen -t )"
        mkdir -p /var/adm/oss/opentasks/
        echo "name: $name" >> /var/adm/oss/opentasks/$TASK
        echo "ip: $ip" >> /var/adm/oss/opentasks/$TASK
        echo "mac: $mac" >> /var/adm/oss/opentasks/$TASK
        echo "wlanip: $wlanip" >> /var/adm/oss/opentasks/$TASK
        echo "wlanmac: $wlanmac" >> /var/adm/oss/opentasks/$TASK
        exit 1
}

while read a
do
  b=${a/:*/}
  if [ "$a" != "${b}:" ]; then
     c=${a/$b: /}
  else
     c=""
  fi
  case $b in
    name)
      name="${c}"
    ;;
    ip)
      ip="${c}"
    ;;
    mac)
      mac="${c}"
    ;;
    wlanip)
      wlanip="${c}"
    ;;
    wlanmac)
      wlanmac="${c}"
    ;;
  esac
done

passwd=$( grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//' )

samba-tool dns add localhost $SCHOOL_DOMAIN $name  A $ip   -U register%"$passwd"
if [ $? != 0 ]; then
   abort
fi
if [ "$wlanip" -a "$wlanmac" ]; then
	samba-tool dns add localhost $SCHOOL_DOMAIN "${name}-wlan"  A $wlanip   -U register%"$passwd"
	if [ $? != 0 ]; then
	   abort
	fi
fi

