#!/usr/bin/python3
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#
import configparser
import os
import sys
import re
import json
import cranixconfig
from configobj import ConfigObj

domain = cranixconfig.CRANIX_WORKGROUP
config = ConfigObj("/opt/cranix-java/conf/cranix-api.properties")
passwd = config['de.cranix.dao.User.Register.Password']

os.system('chgrp -R "{0}\Domain Admins" /var/lib/samba/drivers'.format(domain))
os.system('chmod -R 2775 /var/lib/samba/drivers')
os.system('net rpc rights grant "BUILTIN\Administrators" SePrintOperatorPrivilege -U "register%{0}"'.format(passwd))
config = configparser.ConfigParser(delimiters=('='))
config.read('/etc/samba/smb.conf')

config.set('global','printing','CUPS')
config.set('global','load printers','no')
config.set('global','rpc_server:spoolss','external')
config.set('global','rpc_daemon:spoolssd','fork')

if 'printers' in config:
    config.remove_section('printers')
if 'print$' in config:
    config.remove_section('print$')
config.add_section('print$')
config.set('print$','comment','Printer Drivers')
config.set('print$','path','/var/lib/samba/drivers')
config.set('print$','read only','No')

for line in os.popen('LANG=en_EN lpc status').readlines():
    match = re.search("([\-\w]+):", line)
    if match:
        name =  match.group(1)
        if not name in config:
            config.add_section(name)
        config.set(name,'path','/var/tmp/')
        config.set(name,'printable','yes')
        config.set(name,'printer name',name)
        if 'hosts allow' not in config[name]:
            config.set(name,'hosts allow','')

with open('/etc/samba/smb.conf','wt') as f:
    config.write(f)

