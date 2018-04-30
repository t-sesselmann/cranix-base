#!/bin/bash

cn=$1

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb cn=$cn  gidNumber  | grep gidNumber: | sed 's/gidNumber: //'

