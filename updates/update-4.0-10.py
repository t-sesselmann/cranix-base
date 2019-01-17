#!/usr/bin/python
import json
import os
import os.path
from configobj import ConfigObj

if os.path.exists("/var/adm/oss/update-4.0-10"):
  print "Update 4.0-10 was already installed"
  os.exit(0)
devices=json.load(os.popen('oss_api.sh GET devices/all'))
domain=os.popen('oss_api_text.sh GET system/configuration/DOMAIN').read()
netmask=int(os.popen('oss_api_text.sh GET system/configuration/NETMASK').read().rstrip())
network=os.popen('oss_api_text.sh GET system/configuration/NETWORK').read().split('.')
revdomain=""
print netmask
if netmask > 23:
  revdomain = network[2]+'.'+network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
elif netmask > 15 and netmask < 24:
  revdomain = network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
elif netmask > 7 and netmask < 16:
  revdomain = network[0]+'.IN-ADDR.ARPA'

config = ConfigObj("/opt/oss-java/conf/oss-api.properties")
passwd = config['de.openschoolserver.dao.User.Register.Password']
os.system("samba-tool dns zonecreate localhost " + revdomain + " -U register%" + passwd)
for device in devices:
  ip   = device["ip"].split('.')
  name = device["name"]
  if netmask > 23:
    if ip[0] != network[0] or ip[1] != network[1] or ip[2] != network[2]:
      next
    rdomain = ip[3]
  elif netmask > 15:
    if ip[0] != network[0] or ip[1] != network[1]:
      next
    rdomain = ip[3]+'.'+ip[2]
  elif netmask > 7:
    if ip[0] != network[0]:
      next
    rdomain = ip[3]+'.'+ip[2]+'.'+ip[1]
  os.system("samba-tool dns add localhost " + revdomain + " " + rdomain + " PTR " + name + "." + domain + "  -U register%" + passwd )

with open("/var/adm/oss/update-4.0-10", "w") as f:
  f.write("done")

