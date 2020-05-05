#!/bin/bash

cn=$1

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb "(&(!(objectClass=computer))(cn=$cn))" dn  | grep dn:

