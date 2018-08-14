#!/bin/bash
DNSBASE=$( ldbsearch -H /var/lib/samba/private/sam.ldb  CN=Administrator dn | grep dn: | sed 's/dn: CN=Administrator,CN=Users,//' )
ldbsearch -H /var/lib/samba/private/sam.ldb -b CN=MicrosoftDNS,DC=DomainDnsZones,$DNSBASE -s one '(!(name=RootDNSServers))' name  | grep name: | sed 's/name: //'
