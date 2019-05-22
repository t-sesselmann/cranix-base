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

if type(softwares[minion]) == dict:
   for software in softwares[minion]:
     if re.match(r'Update for ',software):
           next
     version=softwares[minion][software]
     name=re.sub(version,"",software).strip()
     new_file, filename = tempfile.mkstemp()
     shash = {}
     shash['name'] = u'' + name
     shash['description'] = u'' + software
     shash['version'] = version
     try:
        fobj = open(filename,"w")
        fobj.write(json.dumps(shash,sort_keys=True,ensure_ascii=False,encoding="utf-8"))
        fobj.close()
     except UnicodeEncodeError:
        print u'Could not write software'
     else:
        os.close(new_file)
        result=json.load(os.popen('/usr/sbin/oss_api_post_file.sh softwares/devicesByName/'+hostname+' '+filename))
     finally:
        os.remove(filename)
