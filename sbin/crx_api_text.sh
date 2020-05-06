#!/bin/bash
# Copyright 2017 Peter Varkoly <peter@varkoly.de>

METHOD=$1
CALL=$2
DATA=$3
if [ "$DATA" ]; then
   DATAFILE=$( mktemp /tmp/CRANIX_APIXXXXXXXXXXX )
   echo "$DATA" > $DATAFILE
   DATA=" -d @${DATAFILE}"
fi

TOKEN=$( grep de.cranix.api.auth.localhost= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.api.auth.localhost=//' )
curl -s -X $METHOD --header 'Content-Type: application/json' --header 'Accept: text/plain' $DATA --header 'Authorization: Bearer '${TOKEN} "http://localhost:9080/api/$CALL"
if [ "${DATAFILE}" ]; then
    rm ${DATAFILE}
fi

