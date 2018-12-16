#!/usr/bin/python
import json
import os
import sys
from configobj import ConfigObj
config = ConfigObj("/opt/oss-java/conf/oss-api.properties")
passwd = config['de.openschoolserver.dao.User.Register.Password']
name=""
ip=""

for line in sys.stdin:
  kv = line.rstrip().split(": ",1)
  if kv[0] == "ip":
    ip=kv[1].split('.')
  elif kv[0] == "name":
    name=kv[1]
  
domain=os.popen('oss_api_text.sh GET system/configuration/DOMAIN').read()
netmask=int(os.popen('oss_api_text.sh GET system/configuration/NETMASK').read().rstrip())
network=os.popen('oss_api_text.sh GET system/configuration/NETWORK').read().split('.')
revdomain=""
if netmask > 23:
  revdomain = network[2]+'.'+network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
  rdomain = ip[3]
elif netmask > 15:
  revdomain = network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
  rdomain = ip[3]+'.'+ip[2]
elif netmask > 7:
  revdomain = network[0]+'.IN-ADDR.ARPA'
  rdomain = ip[3]+'.'+ip[2]+'.'+ip[1]

if os.system("samba-tool dns delete localhost " + revdomain + " " + rdomain + " PTR " + name + "." + domain + "  -U register%" + passwd ) != 0
  TASK = "/var/adm/oss/opentasks/101-delete-device-" + os.popen('uuidgen -t').read().rstrip()
  with open(TASK, "w") as f:
    f.write("ip: "+','.join(ip))
    f.write("name: "+name) 

