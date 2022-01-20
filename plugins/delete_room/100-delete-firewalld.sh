#!/bin/bash

abort() {
        TASK="delete_room-$( uuidgen -t )"
        mkdir -p /var/adm/cranix/opentasks/
        echo "name: $name" >> /var/adm/cranix/opentasks/$TASK
        echo "start: $start" >> /var/adm/cranix/opentasks/$TASK
        echo "netmask: $netmask" >> /var/adm/cranix/opentasks/$TASK
        echo "hwconf: $hwconf" >> /var/adm/cranix/opentasks/$TASK
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
    startip)
      startip="${c}"
    ;;
    netmask)
      netmask="${c}"
    ;;
    hwconf)
      hwconf="${c}"
    ;;
  esac
done

/usr/bin/firewall-offline-cmd --delete-zone=${name}
#We can not remove it but make it inaktive
/usr/bin/firewall-cmd --zone=${name} --remove-source="${startip}/${netmask}"
/usr/bin/firewall-cmd --zone="external" --remove-rich-rule="rule family=ipv4 source address=${startip}/${netmask} masquerade"

