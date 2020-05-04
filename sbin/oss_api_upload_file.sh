#!/bin/bash
# Copyright Peter Varkoly <peter@varkoly.de>

CALL=$1
DATA=$2
DATA=" -F file=@${DATA}"

TOKEN=$( grep de.openschoolserver.api.auth.localhost= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.openschoolserver.api.auth.localhost=//' )
curl -s -X POST --header 'Content-Type: multipart/form-data' $DATA --header 'Authorization: Bearer '${TOKEN} "http://localhost:9080/api/$CALL"

