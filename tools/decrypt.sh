#!/bin/bash
TOKEN=$( grep javax.persistence.jdbc.password= /opt/cranix-java/conf/cranix-api.properties | sed 's/javax.persistence.jdbc.password//' )
base64 -d | openssl rc2-64-cbc -d -nosalt  -k ${TOKEN} 2>/dev/null
