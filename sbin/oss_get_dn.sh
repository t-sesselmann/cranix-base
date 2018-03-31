#!/bin/bash

cn=shift

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb cn=$uid dn  | grep dn:

