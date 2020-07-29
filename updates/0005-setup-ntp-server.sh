#!/bin/bash

if [ !-e /usr/share/cranix/templates/top.sls -a -e /srv/salt/ntp_conf.sls ]; then
	cp /usr/share/cranix/setup/templates/top.sls /usr/share/cranix/templates/top.sls
fi
