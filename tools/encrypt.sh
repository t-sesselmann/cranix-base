#!/bin/bash
TOKEN=$( grep javax.persistence.jdbc.password= /opt/oss-java/conf/oss-api.properties | sed 's/javax.persistence.jdbc.password//' )

openssl rc2-64-cbc -nosalt  -k ${TOKEN} | base64 -w 0
