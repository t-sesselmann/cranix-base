#!/usr/bin/python
import json
import os
import sys
import re
import tempfile

minion=sys.argv[1]
hostname=minion.split('.')[0]
print hostname

softwares=json.load(os.popen('salt --out=json '+minion+' pkg.list_pkgs'))

for software in softwares[minion]:
    if re.match(r'Update for ',software):
        next
    version=softwares[minion][software]
    name=re.sub(version,"",software).strip()
    new_file, filename = tempfile.mkstemp()
    os.write(new_file,'{"name"="'+name+'","description"="'+software+'","version"="'+version+'"}')
    os.close(new_file)
    result=json.load(os.popen('/usr/sbin/oss_api_post_file.sh softwares/devicesByName/'+hostname+' '+filename))
    os.reomve(filename)

