#!/bin/bash
# Check and repair the system if necessary.

. /etc/sysconfig/cranix 
registerpw=$( /usr/bin/grep de.cranix.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.dao.User.Register.Password=//' )

samba-tool group addmembers "Administrators" register
samba-tool group addmembers "Sysadmins" register
samba-tool group addmembers "Print Operators" register
net rpc rights grant "$CRANIX_WORKGROUP\\register" SePrintOperatorPrivilege -U register%"$registerpw"


HASUID=$( ldbsearch -H /var/lib/samba/private/sam.ldb uid=register uid  | grep uid: )
if [ -z "$HASUID" ]; then
	UIDNUMBER=$( id -u register )
	if [ -z "$UIDNUMBER" ]; then
		UIDNUMBER=$( /usr/share/cranix/tools/get_next_id )
	fi
	if [ -z "$CRANIX_FILESERVER_NETBIOSNAME" ]; then
		CRANIX_FILESERVER_NETBIOSNAME="admin"
	fi

	DN=$( /usr/sbin/crx_get_dn.sh register )
	echo "$DN
changetype: modify
add: uid
uid: register
-
add: uidNumber
uidNumber: $UIDNUMBER
-
add: unixHomeDirectory
unixHomeDirectory: /home/sysadmins/register
-
add: gidNumber
gidNumber: 100
-
add: loginShell
loginShell: /bin/bash
-
add: msSFU30NisDomain
msSFU30NisDomain: $CRANIX_WORKGROUP
-
add: msSFU30Name
msSFU30Name: register
-
add: homeDirectory
homeDirectory: \\\\$CRANIX_FILESERVER_NETBIOSNAME\\register
-
add: homeDrive
homeDrive: Z:
-
add: scriptPath
scriptPath: register.bat
-
add: profilePath
profilePath: \\\\$CRANIX_FILESERVER_NETBIOSNAME\\profiles\\register
"  > /tmp/rfc2307-register
	ldbmodify  -H /var/lib/samba/private/sam.ldb  /tmp/rfc2307-register

fi
