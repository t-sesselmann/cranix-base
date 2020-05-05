#!/usr/bin/python3
# -*- coding: utf-8 -*-

# Copyright 2020 (c) Peter Varkoly <peter@varkoly.de> All rights reserved.

import json
import os
import sys

software=sys.argv[1]

sid=0

try:
    sid=int(software)
except:
    softwares=json.load(os.popen('crx_api.sh GET softwares/allInstallable'))
    for s in softwares:
        if s['name'] == software:
            sid = int(s['id'])
if sid == 0:
    print("Can not find software: " + software)
    sys.exit(1)

package=json.load(os.popen('crx_api.sh GET softwares/{}'.format(sid)))

del package['id']
for v in package['softwareVersions']:
    del v['id']

for v in package['softwareFullNames']:
    del v['id']

name=package['name']

if not os.path.exists('/srv/salt/win/repo-ng/{}/HASH.json'.format(name)):
    with open('/srv/salt/win/repo-ng/{}/HASH.json'.format(name), 'w') as f:
        f.write(package)

os.system('/usr/bin/tar czf /tmp/{0}.tar.gz /srv/salt/win/repo-ng/{0}/ /srv/salt/packages/{0}.sls'.format(name) )

