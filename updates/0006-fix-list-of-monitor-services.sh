#!/bin/bash
#Copyright Peter Varkoly <pvarkoly@cephalix.eu>
#Enhance the list of monitored services if necessary

source /etc/sysconfig/cranix

if [ "${CRANIX_MONITOR_SERVICES/firewalld/}" = "${CRANIX_MONITOR_SERVICES} ]; then
	sed -i "s/CRANIX_MONITOR_SERVICES=.*/CRANIX_MONITOR_SERVICES=\"${CRANIX_MONITOR_SERVICES} firewalld\"/" /etc/sysconfig/cranix
fi
