#!/bin/bash

. /etc/sysconfig/cranix

cn=$1
role=$2
uidNumber=$3

DN=$( /usr/sbin/crx_get_dn.sh $1 )
echo "$DN
changetype: modify
add: uid
uid: ${cn}
-
add: uidNumber
uidNumber: ${uidNumber}
-
add: unixHomeDirectory
unixHomeDirectory: /home/${role}/${cn}
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
msSFU30Name: ${cn}
-
add: homeDirectory
homeDirectory: \\\\${CRANIX_FILESERVER_NETBIOSNAME}\\${cn}
-
add: homeDrive
homeDrive: Z:
-
add: scriptPath
scriptPath: ${cn}.bat
-
add: profilePath
profilePath: \\\\${CRANIX_FILESERVER_NETBIOSNAME}\\profiles\\${cn}
"  > /tmp/rfc2307-${cn}
ldbmodify  -H /var/lib/samba/private/sam.ldb  /tmp/rfc2307-${cn}

