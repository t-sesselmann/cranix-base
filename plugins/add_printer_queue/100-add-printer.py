#!/usr/bin/python3
# Copyright 2022 pvarkoly@cephalix.eu

import configparser
import json
import subprocess
import sys

printer = {}
printer = json.loads(sys.stdin.read())

#Add printer to cups
subprocess.run(['/usr/sbin/lpadmin','-p',printer['name'],
               '-P',printer['driverFile'],
               '-o','printer-error-policy=abort-job',
               '-o','PageSize=A4',
               '-v','socket://{0}'.format(printer['hostName'])])

#Remove printer to samba
config = configparser.ConfigParser(delimiters=('='))
config.read('/etc/samba/smb.conf')

if not printer['name'] in config:
    config.add_section(printer['name'])

config.set(printer['name'],'path','/var/tmp/')
config.set(printer['name'],'printable','yes')
config.set(printer['name'],'printer name',printer['name'])
config.set(printer['name'],'hosts allow','')

with open('/etc/samba/smb.conf','wt') as f:
    config.write(f)

subprocess.run(['/usr/sbin/cupsenable',printer['name']])
subprocess.run(['/usr/sbin/cupsaccept',printer['name']])
