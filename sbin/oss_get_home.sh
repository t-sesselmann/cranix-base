#!/bin/bash

uid=$1

/usr/bin/ldbsearch -H /var/lib/samba/private/sam.ldb uid=$uid unixHomeDirectory  | grep unixHomeDirectory: | sed 's/unixHomeDirectory: //'

