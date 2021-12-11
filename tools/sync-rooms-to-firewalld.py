#!/usr/bin/python3
import json
import os

rooms=json.load(os.popen('crx_api.sh GET rooms/all'))
for room in rooms:
  os.system('firewall-offline-cmd --new-zone={0}'.format(room['name']))
  os.system('firewall-offline-cmd --zone={0} --set-description="Zone for Room {0}"'.format(room['name']))
  os.system('firewall-offline-cmd --zone={0} --add-source="{1}/{2}"'.format(room['name'],room['startIP'],room['netMask']))
  os.system('firewall-offline-cmd --zone={0} --set-target=ACCEPT'.format(room['name']))

