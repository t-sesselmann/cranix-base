#!/usr/bin/python3

from configobj import ConfigObj
config = ConfigObj("/opt/cranix-java/conf/cranix-api.properties")
passwd = config['de.cranix.dao.User.Register.Password']

import configparser
import json
import subprocess
import sys

printer = {}
printer = json.loads(sys.stdin.read())

if printer['action'] == 'activateWindowsDriver':
    subprocess.run(["/usr/sbin/cupsaddsmb",
        "-H","localhost",
        "-U","register%{0}".format(passwd),
        printer['name']
        ])
    #program = new String[6];
    #program[0] = "/usr/bin/rpcclient";
    #program[1] = "-U";
    #program[2] = "register%" + this.getProperty("de.cranix.dao.User.Register.Password");
    #program[3] = "localhost";
    #program[4] = "-c";
    #program[5] = "setdriver " + printerName + " " + printerName;
elif printer['action'] == 'enable':
    config = configparser.ConfigParser(delimiters=('='))
    config.read('/etc/samba/smb.conf')
    allowed_rooms = config.get(printer['name'],'hosts allow').split()
    if printer['network'] not in allowed_rooms:
        allowed_rooms.append(printer['network'])
        config.set(printer['name'],'hosts allow'," ".join(allowed_rooms))
        with open('/etc/samba/smb.conf','wt') as f:
            config.write(f)

elif printer['action'] == 'disable':
    config = configparser.ConfigParser(delimiters=('='))
    config.read('/etc/samba/smb.conf')
    allowed_rooms = config.get(printer['name'],'hosts allow').split()
    if printer['network'] in allowed_rooms:
        allowed_rooms.remove(printer['network'])
        config.set(printer['name'],'hosts allow'," ".join(allowed_rooms))
        with open('/etc/samba/smb.conf','wt') as f:
            config.write(f)
