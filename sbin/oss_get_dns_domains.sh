#!/bin/bash
. /etc/sysconfig/schoolserver

BASEDN=$( ldbsearch -H /var/lib/samba/private/sam.ldb "(&(objectClass=domain)(dc=$SCHOOL_WORKGROUP))" dn | grep dn: | sed 's/dn: //' )
ldbsearch -H /var/lib/samba/private/sam.ldb -b CN=MicrosoftDNS,DC=DomainDnsZones,$BASEDN -s one '(!(name=RootDNSServers))' name  | grep name: | sed 's/name: //'
