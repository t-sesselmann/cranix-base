#!/usr/bin/python3

import os
import re

uidNumber=""
objectSid=""
dn=""
for line in os.popen("ldbsearch -H /var/lib/samba/private/sam.ldb '(objectClass=user)' uid uidNumber objectSid"):
    match=re.search("dn: CN=.*",line)
    if match:
        dn=line.strip()
        if uidNumber != "":
            print("dn: " + objectSid)
            print("changetype: modify")
            print("replace: xidNumber")
            print("xidNumber: " + uidNumber)
            print("")
            uidNumber=""
            objectSid=""
        continue
    match=re.search("uidNumber: (.*)",line)
    if match:
        uidNumber=match.group(1)
    match=re.search("objectSid: (.*)",line)
    if match:
        objectSid=match.group(1)

