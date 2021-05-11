#!/bin/bash

abort() {
        TASK="add_room-$( uuidgen -t )"
        mkdir -p /var/adm/oss/opentasks/
        echo "name: $name" >> /var/adm/oss/opentasks/$TASK
        echo "start: $start" >> /var/adm/oss/opentasks/$TASK
        echo "netmask: $netmask" >> /var/adm/oss/opentasks/$TASK
        echo "hwconf: $hwconf" >> /var/adm/oss/opentasks/$TASK
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

firewall-cmd  --permanent --delete-zone=${name}
firewall-cmd --reload
