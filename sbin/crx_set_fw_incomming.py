#!/usr/bin/python3
import json
import os

#First we have to clean up
for port in os.popen('/usr/bin/firewall-cmd --zone=external --list-ports --permanent').read().split():
    os.system('/usr/bin/firewall-cmd --zone=external --remove-port={} --permanent'.format(port))
for service in os.popen('/usr/bin/firewall-cmd --zone=external --list-services --permanent').read().split():
    os.system('/usr/bin/firewall-cmd --zone=external --remove-service={} --permanent'.format(service))
rules=json.loads(input(""))
for rule in rules:
    if rule == "other":
        for port in rules['other'].split():
            if port.endswith("/tcp") or port.endswith("/udp"):
                os.system('/usr/bin/firewall-cmd --zone=external --add-port={} --permanent'.format(port))
            else:
                os.system('/usr/bin/firewall-cmd --zone=external --add-port={0}/tcp --add-port={0}/udp --permanent'.format(port))
    elif rules[rule]:
        os.system('/usr/bin/firewall-cmd --zone=external --add-service={} --permanent'.format(rule))
os.system("/usr/bin/systemctl restart firewalld")

