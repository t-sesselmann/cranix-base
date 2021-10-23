#!/usr/bin/python3
import json
import os

#Read new services and ports from standard input
rules=json.loads(input(""))
#First we have to clean up
ports    = set(os.popen('/usr/bin/firewall-cmd --zone=external --list-ports --permanent').read().split())
services = set(os.popen('/usr/bin/firewall-cmd --zone=external --list-services --permanent').read().split())
#Remove not wanted ports
for port in list(ports - set(rules['ports'])):
    os.system('/usr/bin/firewall-cmd --zone=external --remove-port={}'.format(port))
    os.system('/usr/bin/firewall-cmd --zone=external --remove-port={} --permanent'.format(port))
#Remove not wanted services
for service in list(services - set(rules['services'])):
    os.system('/usr/bin/firewall-cmd --zone=external --remove-service={}'.format(service))
    os.system('/usr/bin/firewall-cmd --zone=external --remove-service={} --permanent'.format(service))

#Set new services
for service in list( set(rules['services']) - services ):
    os.system('/usr/bin/firewall-cmd --zone=external --add-service={} --permanent'.format(service))
    os.system('/usr/bin/firewall-cmd --zone=external --add-service={}'.format(service))
#Set new ports
for port in list( set(rules['ports']) - ports ):
    os.system('/usr/bin/firewall-cmd --zone=external --add-port={} --permanent'.format(port))
    os.system('/usr/bin/firewall-cmd --zone=external --add-port={}'.format(port))

