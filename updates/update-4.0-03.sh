#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-03" ]
then
echo "Patch 4.0-03 already installed"
        exit 0
fi
export HOME="/root/"
if [ $( echo "select count(*) from Acls where group_id=1 and acl='software.manage'" | mysql OSS  | tail -n1 ) = 0 ]; then
	echo "INSERT into Acls VALUES(NULL,NULL,1,'software.manage','Y',1);" | mysql OSS
fi

if [ $( echo "select count(*) from Enumerates where name='apiAcl' and value='software.manage'" | mysql OSS  | tail -n1 ) = 0 ]; then
	echo "insert Into Enumerates values(NULL,'apiAcl','software.manage',6);" | mysql OSS
fi

systemctl restart oss-api

touch /var/adm/oss/update-4.0-03

