#!/usr/bin/python3

import os
import re

xidNumber=""
objectSid=""
dn=""
uidNumber=""
gidNumber=""
for line in os.popen("ldbsearch -H /var/lib/samba/private/idmap.ldb  cn xidNumber"):
    match=re.search("dn: CN=(.*)",line)
    if match:
        objectSid=match.group(1)
        if xidNumber != "":
            for obj in os.popen("ldbsearch -H /var/lib/samba/private/sam.ldb objectSid={} uidNumber gidNumber".format(objectSid) ):
                match=re.search("dn: CN=.*",obj)
                if match:
                    if gidNumber != "" and gidNumber != "100":
                       print(dn)
                       print("changetype: modify")
                       print("replace: gidNumber")
                       print("gidNumber: " + xidNumber)
                       print("")
                    else if gidNumber == "100" and uidNumber != "":
                       print(dn)
                       print("changetype: modify")
                       print("replace: uidNumber")
                       print("uidNumber: " + xidNumber)
                       print("")
                    gidNumber=""
                    uidNumber=""
                    objectSid=""
                    dn=obj.strip()
                    continue
                match=re.search("uidNumber: (.*)",obj)
                if match:
                    uidNumber=match.group(1)
                match=re.search("gidNumber: (.*)",obj)
                if match:
                    gidNumber=match.group(1)
        continue
    match=re.search("xidNumber: (.*)",line)
    if match:
        xidNumber=match.group(1)

