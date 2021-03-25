#!/bin/bash

abort() {
        TASK="delete_device-$( uuidgen -t )"
        mkdir -p /var/adm/cranix/opentasks/
	echo "reason: $1" >> /var/adm/cranix/opentasks/$TASK
        echo "name: $name" >> /var/adm/cranix/opentasks/$TASK
        echo "id: $id" >> /var/adm/cranix/opentasks/$TASK
        echo "deviceType: $deviceType" >> /var/adm/cranix/opentasks/$TASK
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
  case "${b,,}" in
    name)
      name="${c}"
    ;;
    id)
      id="${c}"
    ;;
    devicetype)
      deviceType="${c}"
    ;;
  esac
done

if [ "${id}" -a -d /srv/itool/images/${id} ]; then
	rm -rf /srv/itool/images/${id}/
fi

