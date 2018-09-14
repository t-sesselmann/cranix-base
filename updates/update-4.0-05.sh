#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-05" ]
then
echo "Patch 4.0-05 already installed"
        exit 0
fi
export HOME="/root/"
echo "UPDATE Enumerates set value='DEF' where name='accessType' AND value='DEFAULT';" | mysql OSS

systemctl restart oss-api

touch /var/adm/oss/update-4.0-05

