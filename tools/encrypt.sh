#!/bin/bash
TOKEN=$( grep de.openschoolserver.dao.User.Cephalix.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Cephalix.Password//' )

openssl rc2-64-cbc -nosalt  -k ${TOKEN} | base64
