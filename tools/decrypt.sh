#!/bin/bash
TOKEN=$( grep javax.persistence.jdbc.password= /opt/oss-java/conf/oss-api.properties | sed 's/javax.persistence.jdbc.password//' )

base64 -d | openssl rc2-64-cbc -d -nosalt  -k ${TOKEN}
