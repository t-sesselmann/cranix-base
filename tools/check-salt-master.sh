#!/bin/bash

salt admin pkg.list_pkgs 2> /dev/null | grep 'Failed to authenticate'
if [ $? = 0 ]; then
        systemctl restart salt-master
        systemctl restart crx_salt_event_watcher
fi

