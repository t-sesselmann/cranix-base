#!/usr/bin/python3
import json
import os

all_classes = {}
adhoc_rooms = {}
all_devices = []
dev_pro_user = os.popen('crx_api_text.sh GET system/configuration/CLASS_ADHOC_DEVICE_PRO_USER').read()
dev_count = os.popen('crx_api_text.sh GET system/configuration/CLASS_ADHOC_DEVICE_COUNT').read()
print(dev_pro_user,dev_count)
def collect_datas():
    #Collect all classess
    for c in json.load(os.popen('/usr/sbin/crx_api.sh GET groups/byType/class')):
        all_classes[c['id']] = c['name']
    #Collect all adhoc rooms for classess
    for a in json.load(os.popen('/usr/sbin/crx_api.sh GET adhocrooms/all')):
        if a['studentsOnly'] and a['roomType'] == 'AdHocAccess':
            c_id = a['groupIds'][0]
            if c_id in all_classes:
                adhoc_rooms[c_id] = a['id']
    #Collect the devices
    for a in adhoc_rooms:
        for dev in json.load(os.popen('/usr/sbin/crx_api.sh GET rooms/{0}/devices'.format(adhoc_rooms[a]))):
            all_devices.append(dev)

def create_adhocroom(c_id):
    name  = all_classes[c_id]
    fname = '/tmp/' + name + '_adhoc.json'
    adhocroom = {
            'name': name + '-adhoc',
            'description': 'AdHoc Raum für die Klasse ' +name,
            'devicesProUser': dev_pro_user,
            'devCount': dev_count,
            'studentsOnly': True,
            'roomControl': 'allTeachers',
            'groupIds': [c_id]
            }
    with open(fname, 'w') as fp:
        json.dump(adhocroom, fp, ensure_ascii=False)
    result = json.load(os.popen('/usr/sbin/crx_api_post_file.sh adhocrooms/add '+fname))
    print(result)

collect_datas()

#Create rooms if necessary
for c_id in all_classes:
    if c_id not in adhoc_rooms:
        create_adhocroom(c_id)

