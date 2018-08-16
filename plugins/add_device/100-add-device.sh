#!/bin/bash
. /etc/sysconfig/schoolserver


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
if [ "$wlanip" -a "$wlanmac" ]; then
	samba-tool dns add localhost $SCHOOL_DOMAIN $name  A $wlanip   -U register%"$passwd"
fi

