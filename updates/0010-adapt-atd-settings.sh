#!/bin/bash
. /etc/sysconfig/atd
if [ -z "${ATD_OPTIONS}" ]; then
	sed -i 's/ATD_OPTIONS=.*/ATD_OPTIONS="-b 20"/' /etc/sysconfig/atd
	/usr/bin/systemctl restart atd
fi
