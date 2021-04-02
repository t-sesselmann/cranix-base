#!/bin/bash

if [ -e /run/cranix/multicast-imaging.pid ]; then
	 /usr/sbin/udp-sender --pid-file /run/cranix/multicast-imaging.pid  --kill
fi

for f in $( grep -l "MULTICAST" /srv/tftp/pxelinux.cfg/01-* /srv/tftp/boot/* 2> /dev/null )
do
	rm -f $f
done
