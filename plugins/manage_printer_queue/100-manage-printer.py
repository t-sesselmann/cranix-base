#!/usr/bin/python3

from configobj import ConfigObj
config = ConfigObj("/opt/cranix-java/conf/cranix-api.properties")
passwd = config['de.cranix.dao.User.Register.Password']

import configparser
import json
import subprocess
import sys
import cranixconfig

try:
    printserver = cranixconfig.CRANIX_PRINTSERVER_NAME
except AttributeError:
    printserver = "printserver"

printer = {}
printer = json.loads(sys.stdin.read())

if printer['action'] == 'activateWindowsDriver':
    subprocess.run(["/usr/sbin/cupsaddsmb",
        "-H",printserver,
        "-U","register%{0}".format(passwd),
        printer['name']
        ])

elif printer['action'] == 'enable':
    config = configparser.ConfigParser(delimiters=('='))
    config.read('/etc/samba/smb-printserver.conf')
    allowed_rooms = config.get(printer['name'],'hosts allow').split()
    if printer['network'] not in allowed_rooms:
        allowed_rooms.append(printer['network'])
        config.set(printer['name'],'hosts allow'," ".join(allowed_rooms))
        with open('/etc/samba/smb-printserver.conf','wt') as f:
            config.write(f)

elif printer['action'] == 'disable':
    config = configparser.ConfigParser(delimiters=('='))
    config.read('/etc/samba/smb-printserver.conf')
    allowed_rooms = config.get(printer['name'],'hosts allow').split()
    if printer['network'] in allowed_rooms:
        allowed_rooms.remove(printer['network'])
        config.set(printer['name'],'hosts allow'," ".join(allowed_rooms))
        with open('/etc/samba/smb-printserver.conf','wt') as f:
            config.write(f)
