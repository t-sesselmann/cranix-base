#!/bin/bash

TOKEN=$( grep de.openschoolserver.api.auth.localhost= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.api.auth.localhost=//' )

while true
do
        read IP
        curl -X GET --header 'Content-Type: application/json' --header 'Accept: text/plain' $DATA --header 'Authorization: Bearer '${TOKEN} "http://localhost:9080/api/devices/loggedIn/$IP"
done
