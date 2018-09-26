#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-06" ]
then
echo "Patch 4.0-06 already installed"
        exit 0
fi
export HOME="/root/"

if [ $( echo "select count(*) from Enumerates where name='roomControl' and value='sysadminsOnly'" | mysql OSS  | tail -n1 ) = 0 ]; then
	echo "insert Into Enumerates values(NULL,'roomControl','sysadminsOnly',6);" | mysql OSS
	echo "UPDATE Rooms set roomConrto='sysadminsOnly' where id=2;" | mysql OSS
fi

systemctl restart oss-api

touch /var/adm/oss/update-4.0-06

