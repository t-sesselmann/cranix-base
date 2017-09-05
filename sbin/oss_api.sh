#!/bin/bash
# Copyright 2017 Peter Varkoly <peter@varkoly.de>

METHOD=$1
CALL=$2
DATA=$3
if [ "$DATA" ]; then
   DATA=" -d ${DATA}"
fi

TOKEN=$( grep de.openschoolserver.api.auth.localhost= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.api.auth.localhost=//' )
curl -X $METHOD --header 'Content-Type: application/json' --header 'Accept: application/json' $DATA --header 'Authorization: Bearer '${TOKEN} "http://localhost:9080/api/$CALL"

