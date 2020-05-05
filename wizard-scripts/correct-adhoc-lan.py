#!/usr/bin/python3
# Srcipt to correct the device if the ip address of the device is not from the room.
# CopyRight Dipl.-Ing. Peter Varkoly <peter@varkoly.de>
import json
import os
import sys
from netaddr import *

rooms=json.load(os.popen('crx_api.sh GET rooms/all'))

for room in rooms:
  id=room['id']
  ip=room['startIP']
  nm=room['netMask']
  net = "{}/{}".format(ip,nm)
  net1 = IPNetwork(net)
  cmd = "crx_api.sh GET rooms/{}/devices".format(id)
  devices=json.load(os.popen(cmd))
  print(net)
  for device in devices:
    net2 = IPNetwork("{}/{}".format(device['ip'],nm))
    if net1 != net2:
       cmd= "crx_api.sh GET rooms/{}/availableIPAddresses".format(id)
       freeip=json.load(os.popen(cmd))
       print("   {} {} new ip {}".format(device['id'], device['ip'], freeip[0]))
       device['ip']=freeip[0]
       fobj = open(device['name'],'w')
       fobj.write(json.dumps(device))
       fobj.close()
       cmd= "/usr/sbin/crx_api_post_file.sh devices/forceModify " + device['name']
       result=json.load(os.popen(cmd))
       print(result)
       nb = raw_input('OK?')
       if nb != 'o':
          sys.exit(1) 

