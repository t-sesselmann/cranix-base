#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-02" ]
then
echo "Patch 4.0-02 already installed"
        exit 0
fi
export HOME="/root/"
if [ $( echo "select count(*) from Acls where group_id=1 and acl='system.dns'" | mysql OSS  | tail -n1 ) = 0 ]; then
	echo "INSERT into Acls VALUES(NULL,NULL,1,'system.dns','Y',1);" | mysql OSS
fi
echo "DELETE From Enumerates WHERE name='roomControl' AND value='teachers';" | mysql OSS

touch /var/adm/oss/update-4.0-02

