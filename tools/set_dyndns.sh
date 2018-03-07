#!/bin/bash
. /etc/sysconfig/schoolserver
sleep $((RANDOM/600))
curl --silent --insecure -X POST --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: text/plain; charset=UTF-8' -d "regcode=$SCHOOL_REG_CODE" 'https://repo.cephalix.eu/api/customers/validateRegcode'  > /dev/null

