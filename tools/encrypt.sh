#!/bin/bash
TOKEN=$( grep javax.persistence.jdbc.password= /opt/cranix-java/conf/cranix-api.properties | sed 's/javax.persistence.jdbc.password//' )
openssl rc2-64-cbc -nosalt  -k ${TOKEN} 2>/dev/null | base64 -w 0
