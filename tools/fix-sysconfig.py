#!/usr/bin/python3

import os
from configobj import ConfigObj

#Create backup directory
backup_dir = '/var/adm/cranix/backup/{0}'.format(os.popen('/usr/share/cranix/tools/crx_date.sh').read()).strip()
os.system('mkdir -p {0}'.format(backup_dir))
os.system('cp {0} {1}'.format('/etc/sysconfig/cranix',backup_dir))

fillup_template = ConfigObj('/usr/share/fillup-templates/sysconfig.cranix',list_values=False,encoding='utf-8')
cranix_conf = ConfigObj('/etc/sysconfig/cranix',list_values=False,encoding='utf-8')

for key in fillup_template:
    if key in cranix_conf:
        fillup_template[key] = cranix_conf[key]
fillup_template.filename = '/etc/sysconfig/cranix'
fillup_template.write()

