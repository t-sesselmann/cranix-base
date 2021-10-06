#!/usr/bin/python3
import json
import os

rooms=json.load(os.popen('crx_api.sh GET rooms/all'))
for room in rooms:
  p = os.popen("/usr/share/cranix/plugins/add_room/100-add-firewalld.sh","w")
  p.write("name: {}\nstartip: {}\nnetmask: {}\n".format(room['name'],room['startIP'],room['netMask']))
  p.close()

