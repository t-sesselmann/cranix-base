#!/usr/bin/python3
#
# Copyright (C) 2021 Peter Varkoly <pvarkoly@cephalix.eu> Nuremberg, Germany.  All rights reserved.
#
import os
import json

input_file   = sys.argv[1]
devices_move = []
new_devices  = "room;name;mac;hwconf;owner\n"

#Take care that all class has an adhoc room
os.system('/usr/share/cranix/tools/handle_class_adhoc_rooms.py')
with open(input_file) as fp:
    devices_move = json.load(fp)

for user in devices_move:
    uid=user['uid']
    old=user['old']
    new=user['new'] + '-adhoc'
    devices = json.load(os.popen('/usr/sbin/crx_api.sh GET users/text/' + uid + '/devices/' + old))
    for device in devices:
        result = json.load(os.popen('/usr/sbin/crx_api.sh DELETE devices/{0}/remove'.format(device['id'])))
        new_devices += "{0};{1};{2};BYOD;{3}\n".format(new,device['name'],device['mac'],uid)

output_file  = input_file.replace('.json','.csv')
with open(output_file, 'w') as fp:
    fp.write(new_devices)

result = json.load(os.popen('/usr/sbin/crx_api_upload_file.sh devices/import ' + output_file))

