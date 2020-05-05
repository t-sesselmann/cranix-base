#!/bin/bash
client=$1
if [ -z "${client}" ]; then
	echo ""
	echo "Usage: crx_dump_dns_domain.sh <client>"
	echo ""
	exit 1
fi
. /etc/sysconfig/schoolserver
passwd=$( grep de.openschoolserver.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//' )
salt "${client}.${CRANIX_DOMAIN}" system.unjoin_domain domain="${CRANIX_DOMAIN}" username='register' password="${passwd}" restart=True

