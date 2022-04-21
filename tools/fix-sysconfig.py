#!/usr/bin/python3

from configobj import ConfigObj

fillup_template = ConfigObj('/usr/share/fillup-templates/sysconfig.cranix',list_values=False,encoding='utf-8')
cranix_conf = ConfigObj('/etc/sysconfig/cranix',list_values=False,encoding='utf-8')

for key in fillup_template:
    if key in cranix_conf:
        fillup_template[key] = cranix_conf[key]
fillup_template.filename = '/etc/sysconfig/cranix'
fillup_template.wirte()

