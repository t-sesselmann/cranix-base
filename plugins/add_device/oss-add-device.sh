#!/bin/bash
. /etc/sysconfig/schoolserver


while read a
do
  b=${a/:*/}
  c=${a/$b: /}
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

passwd=$( grep de.openschoolserver.dao.User.Cephalix.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Cephalix.Password=//' )

samba-tool dns add localhost $SCHOOL_DOMAIN $name  A $ip   -U cephalix%"$passwd"
if [ "$wlanip" -a "$wlanmac" ]; then
	samba-tool dns add localhost $SCHOOL_DOMAIN $name  A $wlanip   -U cephalix%"$passwd"
fi

