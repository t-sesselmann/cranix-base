#!/usr/bin/python3
import json
import os

groups=json.load(os.popen('crx_api.sh GET groups/all'))
for group in groups:
    print(group)
    name        = group["name"]
    description = group["description"]
    grouptype   = group["groupType"]
    print("name: {}\ndescription: {}\ngrouptype: {}".format(name,description,grouptype))
#  p = os.popen("/usr/share/cranix/plugins/add_group/100-add-group.sh","w")
#  p.write("name: {}\ndescription: {}\n grouptype: {}".format(name,description,grouptype))
#  p.close()

