#!/bin/bash
. /etc/sysconfig/schoolserver
sleep $((RANDOM/600))
curl --silent --insecure -X GET "${SCHOOL_UPDATE_URL}/api/customers/regcodes/${SCHOOL_REG_CODE}" > /dev/null
