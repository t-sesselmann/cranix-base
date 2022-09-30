#!/bin/bash

/usr/share/cranix/tools/wait-for-api.sh
/usr/share/cranix/tools/remove-internal-device-from-firewall.sh
/usr/sbin/crx_manage_room_access.py --all --set_defaults
if [ -e /usr/share/cranix/tools/custom/fw-post-start.sh ]; then
        /usr/share/cranix/tools/custom/fw-post-start.sh
fi

