#!/bin/bash

uid=$1

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb uid=$uid uidNumber  | grep uidNumber: | sed 's/uidNumber: //'

