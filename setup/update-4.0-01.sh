#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-01" ]
then
echo "Patch 4.0-01 already installed"
        exit 0
fi

echo "Alter TABLE Categories add column publicAccess CHAR(1) DEFAULT 'N' after studentsOnly;" | mysql OSS

systemctl restart oss-api

touch /var/adm/oss/update-4.0-01

