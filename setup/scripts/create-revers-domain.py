#!/usr/bin/python
import os
import sys

passwd=sys.argv[1]
domain=sys.argv[2]
network=sys.argv[3].split('.')
netmask=sys.argv[4]
devices=sys.argv[5].split(',')
revdomain=""
if netmask > 23:
  revdomain = network[2]+'.'+network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
elif netmask > 15 and netmask < 24:
  revdomain = network[1]+'.'+network[0]+'.IN-ADDR.ARPA'
elif netmask > 7 and netmask < 16:
  revdomain = network[0]+'.IN-ADDR.ARPA'
os.system("samba-tool dns zonecreate localhost " + revdomain + " -U Administrator%" + passwd)

for device in devices:
  name = device.split(':')[0]
  ip   = device.split(':')[1].split('.')
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
  os.system("samba-tool dns add localhost " + revdomain + " " + rdomain + " PTR " + name + "." + domain + "  -U Administrator%" + passwd )

