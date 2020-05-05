#!/bin/bash
. /etc/sysconfig/schoolserver
sleep $((RANDOM/600))
curl --silent --insecure -X GET "${CRANIX_UPDATE_URL}/api/customers/regcodes/${CRANIX_REG_CODE}" > /dev/null
