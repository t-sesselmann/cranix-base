#!/usr/bin/python
import json
import os

rooms=json.load(os.popen('oss_api.sh GET rooms/all'))
for room in rooms:
    f = os.system("/usr/share/oss/plugins/add_room/100-add-firewalld.sh","w")
    f.write(json.dumps(rooms,sort_keys=True,ensure_ascii=False,encoding="utf-8"))
    f.close
