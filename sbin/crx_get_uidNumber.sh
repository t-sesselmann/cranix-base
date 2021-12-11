#!/bin/bash

uid=$1

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb "uid=$uid" uidNumber  | /usr/bin/grep uidNumber: | /usr/bin/sed 's/uidNumber: //'

