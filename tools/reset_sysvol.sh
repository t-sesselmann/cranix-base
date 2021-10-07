#!/bin/bash

ACLS='group::rwx
group:BUILTIN\\administrators:rwx
group:BUILTIN\\server\040operators:r-x
group:NT\040AUTHORITY\\system:rwx
group:NT\040AUTHORITY\\authenticated\040users:r-x
mask::rwx
other::---
default:user::rwx
default:user:root:rwx
default:user:BUILTIN\\administrators:rwx
default:group::---
default:group:BUILTIN\\administrators:rwx
default:group:BUILTIN\\server\040operators:r-x
default:group:NT\040AUTHORITY\\system:rwx
default:group:NT\040AUTHORITY\\authenticated\040users:r-x
default:mask::rwx
default:other::---'

setfacl -R --remove-all /var/lib/samba/sysvol/
chown -R root /var/lib/samba/sysvol
chgrp -R "BUILTIN\\administrators" /var/lib/samba/sysvol

for i in ${ACLS}
do
	setfacl -Rm "$i" /var/lib/samba/sysvol
done

