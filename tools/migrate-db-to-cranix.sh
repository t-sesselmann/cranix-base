#!/bin/bash
if [ ! -e /etc/products.d/CRANIX.prod ]; then
	echo "Can be executed only after successfull migration to CRANIX."
        exit 0
fi
CALLER=$( cat /proc/$PPID/comm )
export HOME="/root"
CRANIX=$( echo "show tables" | mysql CRX | grep CrxNextID )
if [ "${CRANIX}" ];  then
        exit 0
fi

DATE=$( date +%Y-%m-%d-%H-%M )
echo "INSERT INTO Enumerates VALUES(NULL,'apiAcl','hwconf.modify',6);" | mysql OSS
mysqldump --databases OSS | gzip > OSS-BACKUP-${DATE}.sql.gz

echo "RENAME TABLE OssNextID TO CrxNextID;"     | mysql OSS
echo "RENAME TABLE OSSConfig  TO CrxConfig"     | mysql OSS
echo "RENAME TABLE OSSMConfig TO CrxMConfig"    | mysql OSS
echo "RENAME TABLE OssResponses TO CrxResponse" | mysql OSS
mysqldump --databases OSS > CRX.sql
sed -i '1,26s/OSS/CRX/' CRX.sql
mysql < CRX.sql
password=$( mktemp cranixXXXXXXXXXXXX )
if [ -e /opt/oss-java/conf/oss-api.properties.rpmsave ]; then
        cp /opt/cranix-java/conf/cranix-api.properties /opt/cranix-java/conf/cranix-api.properties.orig
        sed s/openschoolserver/cranix/ /opt/oss-java/conf/oss-api.properties.rpmsave > /opt/cranix-java/conf/cranix-api.properties
        rm /opt/oss-java/conf/oss-api.properties.rpmsave
fi
if [ -e /opt/oss-java/conf/config.yml.rpmsave ]; then
        cp /opt/cranix-java/conf/config.yml /opt/cranix-java/conf/config.yml.orig
	sed s/openschoolserver/cranix/g /opt/oss-java/conf/config.yml.rpmsave > /opt/cranix-java/conf/config.yml
	rm /opt/oss-java/conf/config.yml.rpmsave
fi
sed -i s/javax.persistence.jdbc.password=.*$/javax.persistence.jdbc.password=${password}/ /opt/cranix-java/conf/cranix-api.properties
sed -i 's/=claxss/=cranix/' /opt/cranix-java/conf/cranix-api.properties
echo "grant all on CRX.* to 'cranix'@'localhost'  identified by '$password'" | mysql
mkdir -p /var/adm/cranix/

if [ -e /opt/cranix-java/data/adapt-cephalix-to-cranix.sh ]; then
	/opt/cranix-java/data/adapt-cephalix-to-cranix.sh
	systemctl restart cephalix-api
else
	systemctl restart cranix-api
fi

